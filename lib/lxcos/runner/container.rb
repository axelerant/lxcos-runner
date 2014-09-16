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
	Net::SSH.start(active_node['ec2']['public_ipv4'], 'goatos') do |session|
          session.exec!("create_container.rb -n #{name} -t #{type} -m #{memory} -c #{cpus}")
        end
      end
 
    end
  end
end

