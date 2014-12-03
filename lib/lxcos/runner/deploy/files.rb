module Lxcos
  module Runner
    class Files < TaskRunner

      def initialize(params)
        super(params)
        @source_env_name, @destination_env_name = params.fetch(:source_env_name), params.fetch(:destination_env_name)

        @project_name = params.fetch(:project_name)
      end

      def sync
        cmd_params = [
                      "project_name=#{@project_name}",
                      "source_env_name=#{@source_env_name}",
                      "destination_env_name=#{@destination_env_name}"
                     ]

        cmd = "cap projspace environment:sync_files #{cmd_params.join(' ')}"

        run(cmd)
      end

      
    end
  end
end
