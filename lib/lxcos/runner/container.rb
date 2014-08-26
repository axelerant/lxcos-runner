module Lxcos
  module Runner
    class Container
      # attr_accessor :name, :details
      attr_accessor :name, :type, :memory, :cpus, :details
      
      def initialize(name, type, memory, cpus)
          if can_create_container?
            @name = name
            @type = type
            @memory = memory
            @cpus = cpus
            new_container = new_container(@type)
            new_container.clone(@name, 
              flags: LXC::LXC_CLONE_SNAPSHOT, bdev_type: 'overlayfs')
            create_and_start
            set_cgroup_limits
            attach            
          else
            raise "Not allowed to create container"
          end 
      end


      def new_container(type)
        LXC::Container.new(type)
      end

      def create_and_start
        @container = new_container(@name)
        @container.start
        sleep(5)
      end

      def set_cgroup_limits
        @container.set_cgroup_item("memory.limit_in_bytes", @memory)
        @container.set_cgroup_item("cpuset.cpus", @cpus)
      end

      def attach
        @container.attach do 
        #run custom commands inside containers
        end 
      end
 
      def create
        @details = Node.create_container(@name)
      end

      def can_create_container?
        nodes = Lxcos::Runner::Node.all
        nodes.each do |node|
          active = Lxcos::Runner::Node.is_active?(node.first) 
          no_of_containers = Lxcos::Runner::Node.number_of_containers(node.first) 

          active & no_of_containers >= 100
        end
      end

    end
  end
end
