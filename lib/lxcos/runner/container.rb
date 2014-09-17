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
	Net::SSH.start(node_ip, 'goatos') do |session|
	  container_ip = session.exec!("create_container.rb -n #{name} -t #{type} -m #{memory} -c #{cpus}")
        end

	return {node_name: active_node.name,
		node_ip: node_ip,
		container_ip: container_ip
		}
      end
 
    end
  end
end

