module Lxcos
  module Runner
    class Environment < TaskRunner

      def initialize(params)
        super(params)
        @server_name, @name, @project_name, @server_host, @server_user, @container_user, @container_host = params.fetch(:server_name),
            params.fetch(:environment_name), params.fetch(:project_name), params.fetch(:server_host), params(:server_user),
            params.fetch(:container_user), params(:@container_host)


        if params.has_key? :http_lock
          @http_lock_uname, @http_lock_pwd = params[:http_lock].fetch(:http_lock_uname), 
                                             params[:http_lock].fetch(:http_lock_pwd) 
        end 
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

        #format dbname||dbuser||dbpass||site||site_security||http_lock_uname||http_lock_pwd" 
        #credset = output.split.last.split("||")
        

        # {environment_name: @name,
        #   db_name: output[0],
        #   db_user: output[1],
        #   db_password: output[2],
        #   site_http_url: output[3]
        # }

        db_credential = ""
        Net::SSH.start(@server_host, @server_user) do |session|
          credential = session.exec!("ssh -o LogLevel=quiet -A -t -t -o StrictHostKeyChecking=no #{@container_user}@#{@container_host} 'credential #{@project_name} #{@name}'")
          db_credential = credentials.split("|")[2]
        end

        #hardcode output, cannot parse now
        { db_name: "#{@project_name}#{@name}",
          db_user: "#{@project_name}#{@name}",
          db_password: db_credential,
          site_http_url: "http://#{@project_name}.#{@name}.#{node_name}.lxcos.io",
          site_security: true,
          http_lock_uname: "#{@project_name}",
          http_lock_pwd: "#{@project_name}"
        }
      end

      def lock
        cmd_params = [
                      "project_name=#{@project_name}",
                      "environment_name=#{@name}",
                      "http_lock_uname=#{@http_lock_uname}",
                      "http_lock_pwd=#{@http_lock_pwd}"

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
