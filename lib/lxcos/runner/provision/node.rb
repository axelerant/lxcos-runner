require 'route53'

module Lxcos
  module Runner
    module Node

      CREATE_NODE_CONTAINER_COUNT = 90
      MAX_CONTAINERS_IN_NODE = 100

      def self.current
        active_node = get_active_node
	if active_node.nil?
	  p "No active node, creating new"
          create_new_node
          active_node = commission_and_get_ready_node
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

            active_node = commission_and_get_ready_node
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
        knife_custom_config = Chef::Config[:knife]
        
        node_name = get_new_name
        ebs_root_vol_size = knife_custom_config[:ebs_root_vol_size]
        security_group = knife_custom_config[:security_group]
        run_list = knife_custom_config[:runlist]
        username = knife_custom_config[:winrm_username]
        aws_key_path = knife_custom_config[:aws_ssh_pem_file_location]

        #Command to provision the instance
        provision_cmd = [
			 "ec2_hostname",
                         "knife ec2 server create",
                         "-r #{run_list}",
                         "-G #{security_group}",
                         "-x #{username}",
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
        knife_config = Chef::Config[:knife]
        conn = Route53::Connection.new(knife_config[:aws_access_key_id],
                                       knife_config[:aws_secret_access_key]) #opens connection
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

      def self.get_new_name
        random_word_api_endpoint = URI('http://randomword.setgetgo.com/get.php')
        res = Net::HTTP.get_response(random_word_api_endpoint)
        
        raise "Random word generator service did not " +
              "respond while trying to generate name for node." unless (200..299).include? res.code.to_i

        random_word = res.body.downcase.chomp
        random_word.concat(".lxcos.io")
      end

      def self.get_active_node
        get_node_with_tag("active")
      end

      def self.commission_and_get_ready_node
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

