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

        #format dbname||dbuser||dbpass||site||site_security||http_lock_uname||http_lock_pwd" 
        #credset = output.split.last.split("||")
        

        # {environment_name: @name,
        #   db_name: output[0],
        #   db_user: output[1],
        #   db_password: output[2],
        #   site_http_url: output[3]
        # }

        #hardcode output, cannot parse now
        { db_name: "#{@project_name}#{@name}",
          db_user: "#{@project_name}#{@name}",
          db_password: "#{@project_name}#{@name}",
          site_http_url: "http://#{@project_name}.#{@name}.projspace.com",
          site_security: true,
          http_lock_uname: "#{@project_name}",
          http_lock_pwd: "#{@project_name}"
        }
      end

      def lock
        cmd_params = [
                      "project_name=#{@project_name}",
                      "environment_name=#{@name}"
                     ]
        cmd = "cap projspace environment:lock_site #{cmd_params.join(' ')}"   
        run(cmd)
      end

      def unlock
        cmd_params = [
                      "project_name=#{@project_name}",
                      "environment_name=#{@name}"
                     ]
        cmd = "cap projspace environment:unlock_site #{cmd_params.join(' ')}"   
        run(cmd)
      end

    end
  end
end
