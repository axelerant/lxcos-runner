module Lxcos
  module Runner
    class Code < TaskRunner

      def initialize(params)
        super(params)
        @repo_url, @environment_name, @project_name,
        @repo_branch = params.fetch(:repo_url), params.fetch(:environment_name), params.fetch(:project_name), params.fetch(:repo_branch, "master")
      end
        
      def deploy
        cmd_params = [
                      "project_name=#{@project_name}",
                      "repo_url=#{@repo_url}",
                      "environment_name=#{@environment_name}",
                      "repo_branch=#{@repo_branch}"
                     ]

        cmd = "cap projspace environment:deploy_code #{cmd_params.join(' ')}"

        run(cmd)
      end
    end
  end
end
