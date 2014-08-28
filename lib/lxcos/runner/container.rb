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
      end
 
      def create
        @details = Node.create_container(@name)
      end
    end
  end
end

