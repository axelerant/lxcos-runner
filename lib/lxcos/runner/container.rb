module Lxcos
  module Runner
    class Container
      attr_accessor :name, :details
      
      def initialize(name)
        @name = name
      end

      def create
        @details = Node.create_container(name)
      end

    end
  end
end
