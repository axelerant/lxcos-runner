module Lxcos
  module Runner
    class Container
      attr_accessor :name, :type, :memory, :cpus
      
      def initialize(name, type, memory = "256M", cpus = 0)
        @name = name
        @type = type
        @memory = memory
        @cpus = cpus
      end

      def create
        active_node = Node.current
        
	node_ip = active_node['ec2']['public_ipv4']
	container_hash = ""
	Net::SSH.start(node_ip, 'goatos') do |session|
	  container_hash = session.exec!("create_container.rb -n #{name} -t #{type} -m #{memory} -c #{cpus}")
        end

	container_ip = JSON.parse(container_hash)["ip_addr"].first

        Net::SSH.start(node_ip, 'ubuntu') do |session|
          session.exec!("sudo hooks_host -n #{active_node.name} -i #{node_ip} -p #{name}")
          session.exec!("sudo a2ensite #{name}.hooks.#{active_node}.conf && sudo /etc/init.d/apache2 reload")
        end

	Net::SSH.start(node_ip, 'ubuntu') do |session|
          #haproxy cookbook
	  session.exec!("sudo chef-client -o 'role[haproxy]'")

          #passwordless ssh
          session.exec!("sudo add_key_to_container #{name}")
        end

        container_key_ubuntu = "", container_key_www_data = ""
        Net::SSH.start(node_ip, 'goatos') do |session|
          keys = session.exec!("ssh -o LogLevel=quiet -A -t -t -o StrictHostKeyChecking=no ubuntu@#{container_ip} 'gen_keys ubuntu'")
          container_key_ubuntu, container_key_www_data = keys.strip.split("\r\n")
        end

        {node_name: active_node.name,
          node_ip: node_ip,
          container_ip: container_ip,
          container_name: name,
          container_key_ubuntu: container_key_ubuntu,
          container_key_www_data: container_key_www_data
        }
      rescue => e
        puts e
        {}
      end
 
    end
  end
end

