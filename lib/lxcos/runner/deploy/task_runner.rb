require 'open3'

module Lxcos
  module Runner
    class TaskRunner
      protected

      def initialize(params)
        @server_host, @server_user, 
        @container_host, @container_user =params.fetch(:server_host), params.fetch(:server_user, 'goatos'),
        params.fetch(:container_host), params.fetch(:container_user, 'ubuntu')
      end
      
      def run(cmd)
        defaults = [
                    "server_host=#{@server_host}",
                    "server_user=#{@server_user}",
                    "container_host=#{@container_host}",
                    "container_user=#{@container_user}"
                   ]

        full_cmd = "#{cmd} #{defaults.join(' ')}"
        puts "Executing: #{full_cmd}"
        system(full_cmd)

      rescue => e
        puts e
        {}
      end
      
    end
  end
end
