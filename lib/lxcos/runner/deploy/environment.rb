module Lxcos
  module Runner
    class Environment < TaskRunner

      def initialize(params)
        super(params)
        @repo_url, @name, @project_name = params.fetch(:scm_url), params.fetch(:environment_name),
        params.fetch(:project_name)
      end

      def create
        cmd_params = [
                      "project_name=#{@project_name}",
                      "repo_url=#{@repo_url}",
                      "environment_name=#{@name}"
                      ]

        cmd = "cap projspace environment:create #{cmd_params.join(' ')}"
        output = run(cmd)

        #format dbname||dbuser||dbpass||site" 
        credset = output.split.last.split("||")
        
        {environment_name: @name,
          db_name: output[0],
          db_user: output[1],
          db_password: output[2],
          site_http_url: output[3]
        }
      end

    end
  end
end
