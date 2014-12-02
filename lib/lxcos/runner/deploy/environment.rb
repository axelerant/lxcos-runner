module Lxcos
  module Runner
    class Environment < TaskRunner

      def initialize(params)
        super(params)
        @server_name, @name, @project_name = params.fetch(:server_name), params.fetch(:environment_name),
        params.fetch(:project_name)
      end

      def create
        node_name = @server_name.split('.')[0]
        cmd_params = [
                      "project_name=#{@project_name}",
                      "environment_name=#{@name}",
                      "node_name=#{node_name}"
                      ]

        cmd = "cap projspace environment:create #{cmd_params.join(' ')}"
        output = run(cmd)

        #format dbname||dbuser||dbpass||site" 
        #credset = output.split.last.split("||")
        

        # {environment_name: @name,
        #   db_name: output[0],
        #   db_user: output[1],
        #   db_password: output[2],
        #   site_http_url: output[3]
        # }

        #hardcode output, cannot parse now
        {db_name: "#{@project_name}#{@name}",
          db_user: "#{@project_name}#{@name}",
          db_password: "#{@project_name}#{@name}",
          site_http_url: "http://#{@project_name}.#{@name}.projspace.com"
        }
      end

    end
  end
end
