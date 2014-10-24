require 'capistrano/dsl'

module Lxcos
  module Runner
    class Deploy
      include Capistrano::DSL
      def initialize(params)
        load 'capistrano/all.rb'
        set :application, params[:project_name]
        set :repo_url, params[:repo_url]
        set :deploy_to, '/tmp'

        stages = "projspace"
        set :stage, :projspace
        role :app, %w{}
        server 'example.com', user: 'deploy', roles: %w{web app}, my_property: :my_value
        
        load 'capistrano/setup.rb'
        load 'capistrano/deploy.rb'
        Dir.glob('capistrano/tasks/*.rake').each { |r| import r }
      end

      def deploy_code
        Capistrano::Application.invoke("projspace")
        Capistrano::Application.invoke("deploy")
      end

    end
  end
end
