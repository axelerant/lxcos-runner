require 'route53'

module Lxcos
  module Runner
    module Node

      CREATE_NODE_CONTAINER_COUNT = 95
      MAX_CONTAINERS_IN_NODE = 100

      def self.current
        active_node = get_active_node
	if active_node.nil?
	  p "No active node, creating new"
          create_new_node
          active_node = get_ready_node
        else
          total_containers = number_of_containers(active_node)
	  p "Total containers: #{total_containers}"
          if total_containers == CREATE_NODE_CONTAINER_COUNT
            p "#{active_node} has #{CREATE_NODE_CONTAINER_COUNT} containers, creating new node"
            fork do
              create_new_node
            end
          elsif total_containers >= MAX_CONTAINERS_IN_NODE
            mark_node_inactive(active_node.name)

            active_node = get_ready_node
          end
        end
        
	p "Active node: #{active_node.name}"
        active_node
      end


      #List out all the nodes
      def self.all
        Chef::Node.list
      end

      def self.create_new_node
        p "Start creating new node offline"

        node_name = get_new_name
        instance_size = "m1.large"  #For initial testing later to a large instance
        ebs_root_vol_size = 30   # in GB
        region = "us-east-1b"
        ami_name = "ami-7050ae18" #Use this prebaked AMI
        security_group = "goatbase"
        run_list = "role[lxcosbase]"
        username = "ubuntu"
        aws_key_name = "medhuec2" #Key name on the runner machine
        aws_key_path = "/home/ubuntu/medhuec2.pem" #Full path of the key

        #Command to provision the instance
        provision_cmd = [
			 "ec2_hostname",
                         "knife ec2 server create",
                         "-r #{run_list}",
                         "-I #{ami_name}",
                         "--flavor #{instance_size}",
                         "-G #{security_group}",
                         "-Z #{region}",
                         "-x #{username}",
                         "-S #{aws_key_name}",
                         "-N #{node_name}",
                         "-i #{aws_key_path}",
                         "--ebs-size #{ebs_root_vol_size}"
                        ].join(" ")


        #Provision it
        system(provision_cmd) ? 0 : -1
        tag_node(node_name, "ready")
	add_route53_dns(node_name)
        p "Finished creating new node #{node_name}"
      end

      def self.add_route53_dns(node_name)
        conn = Route53::Connection.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]) #opens connection
        zone = conn.get_zones.first
        ip_of_node = Chef::Node.load(node_name)["ec2"]["public_ipv4"]
        dns_base = Route53::DNSRecord.new(node_name,"A","300", [ip_of_node], zone)
        dns_base.create

        dns_sub_domain = Route53::DNSRecord.new("*." + node_name,"A","300", [ip_of_node], zone)
        dns_sub_domain.create
      end

      def self.mark_node_inactive(node_name)
        remove_node_tag(node_name, "active")
      end

      def self.number_of_containers(node)
	container_hash = ""
        Net::SSH.start(node["ec2"]["public_ipv4"], 'goatos') do |session|
          container_hash = session.exec!('number_of_containers.rb')
        end

        JSON.parse(container_hash)["number_of_containers"]
      end

      # fetch random word and write remaining words back to the dictionary except for the random one.
      def self.get_new_name
        words = File.open("/home/ubuntu/test-runner/runner/dictionary.rb", "r").to_a
        random_word = words.sample
        words_remaining = words - [random_word]
        
        if words.empty?
          puts "Dictionary is empty."
        else
          dictionary = File.open("/home/ubuntu/test-runner/runner/dictionary.rb", "w")
          words_remaining.each do |word|
            dictionary.write(word)
          end
          dictionary.close
          random_word.chomp.concat(".lxcos.io")
        end
      end

      def self.get_active_node
        get_node_with_tag("active")
      end

      def self.get_ready_node
        node = get_node_with_tag("ready")
        remove_node_tag(node.name, "ready")
        tag_node(node.name, "active")
        
        node
      end

      def self.tag_node(node_name, tag)
        tag_command = "knife tag create #{node_name} #{tag}"
        system(tag_command)
      end

      # check if node is active
      def self.get_node_with_tag(tag)
        all.each do |node_name, url|
          node = Chef::Node.load(node_name)
          return node if node.tags.include?(tag)
        end

        #no active
        return nil
      end

      def self.remove_node_tag(node_name, tag)
        remove_tag_cmd = "knife tag delete #{node_name} #{tag}"
        system(remove_tag_cmd)
      end

    end

  end
end

