require 'open3'

module Lxcos
  module Runner
    class Deploy
      def initialize(params)
        @project_name, @repo_url, 
        @server_host, @server_user, 
        @password, @scm_branch, @deploy_to_folder = params[:project_name], params[:repo_url], 
        params[:server_host], params[:server_user], params[:password],
        params[:scm_branch], params[:deploy_to_folder]
      end

      def deploy_code
        run(deploy_code_command)
      end

      private
      
      def deploy_code_command
        #cap projspace deploy project_name=dodydeghi repo_url=git@github.com:devaroop/SmsTicketBooking.git server_host=localhost server_user=devaroop deploy_to=/tmp/devaroop branch=master
        params = [
                  "project_name=#{@project_name}",
                  "repo_url=#{@repo_url}",
                  "server_host=#{@server_host}",
                  "server_user=#{@server_user}",
                  "deploy_to=#{@deploy_to_folder}",
                  "branch=#{@scm_branch}"
                  ]

        "cap projspace deploy #{params.join(' ')}"
      end

      def run(cmd)
        puts "Executing: #{cmd}"
        system(cmd)
      end
      
    end
  end
end
