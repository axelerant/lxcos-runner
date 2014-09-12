
module Lxcos
  module Runner
    module Node

      #List out all the nodes
      def self.all
        Chef::Node.list
      end

      def self.current
        active_node = get_active
        if active_node.nil?
          create_new_node
          active_node = get_active
        else
          total_containers = number_of_containers(active_node)
          if total_containers >= 100
            mark_node_inactive(active_node)
            create_new_node
            active_node = get_active
          end
        end
        
        active_node
      end

      def self.mark_node_inactive(node_name)
        remove_tag_cmd = "knife tag delete #{node_name} active"
        system(remove_tag_cmd)
      end

      # Find number of containers in each node
      def self.number_of_containers(node_name)
        Net::SSH.start(node_name, 'goatos') do |session|
          session.exec!('number_of_containers.rb')
        end
      end

      def self.create_new_node
        # Many of these can go into knife.rb file after some initial tweaking.
        aws_access_key_id = "your-aws-access-key-id"
        aws_secret_access_key = "your-aws-secret-access-key"

        #Node details
        node_name = name
        instance_size = "t1.micro"  #For initial testing later to a large instance
        ebs_root_vol_size = 30   # in GB
        region = "us-east-1b"
        ami_name = "ami-7050ae18" #Use this prebaked AMI
        security_group = "goatbase"
        run_list = "role[lxcosbase]"
        username = "ubuntu"
        aws_key_name = "medhuec2" #Key name on the runner machine
        aws_key_path = "/home/ubuntu/medhuec2.pem" #Full path of the key
        tag = "active"

        #Command to provision the instance
        provision_cmd = [
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
                         "-A #{aws_access_key_id}",
                         "-K #{aws_secret_access_key}",
                         "--ebs-size #{ebs_root_vol_size}"
                         "-T active=#{tag}"
                        ].join(" ")


        #Provision it
        system(provision_cmd) ? 0 : -1
      end

      def self.create_container(node_name)
        #create a container in a node
        #should return details of the container
        if self.is_active?(node_name)
          Net::SSH.start(node_name, 'goatos') do |session|
            session.exec!('container.rb')
          end
        end
      end

      # fetch random word and write remaining words back to the dictionary except for the random one.
      def self.name
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

      # check if node is active
      def self.get_active
        all.each do |node_name, url|
          node = Chef::Node.load(node_name)
          return node_name if node.tags.include?('active')
        end

        #no active
        return nil
      end
    end

  end
end

