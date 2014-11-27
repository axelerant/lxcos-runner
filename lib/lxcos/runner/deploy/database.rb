module Lxcos
  module Runner
    class Database < TaskRunner

      def initialize(params)
        super(params)
        @source_db_user, @source_db_password, @source_db_name = params.fetch(:source_db_user), params.fetch(:source_db_password),
        params.fetch(:source_db_name)

        @destination_db_user, @destination_db_password, @destination_db_name = params.fetch(:destination_db_user), 
        params.fetch(:destination_db_password), params.fetch(:destination_db_name)

        @project_name = params.fetch(:project_name)
        @executing_user = params.fetch(:executing_user, 'ubuntu')
      end
      
      def sync
        cmd_params = [
                      "project_name=#{@project_name}",
                      "source_db_password=#{@source_db_password}",
                      "source_db_name=#{@source_db_name}",
                      "source_db_user=#{@source_db_user}",
                      "destination_db_password=#{@destination_db_password}",
                      "destination_db_name=#{@destination_db_name}",
                      "destination_db_user=#{@destination_db_user}",
                      "executing_user=#{@executing_user}"
                     ]

        cmd = "cap projspace environment:sync_database #{cmd_params.join(' ')}"

        run(cmd)
      end

      
    end
  end
end
