module Lxcos
  module Runner
    class Environment < TaskRunner

      def initialize(params)
        super(params)
        @repo_url, @name, @project_name = params.fetch(:scm_url), params.fetch(:env_name),
        params.fetch(:project_name)
      end

      def create
        cmd_params = [
                      "project_name=#{@project_name}",
                      "repo_url=#{@repo_url}",
                      "env_name=#{@name}"
                      ]

        cmd = "cap projspace environment:create #{cmd_params.join(' ')}"
        run(cmd)
      end

    end
  end
end
