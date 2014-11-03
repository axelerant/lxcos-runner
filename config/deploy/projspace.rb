server ENV['server_host'], user: ENV['server_user'], roles: %w{web app}, password: ENV['password']
set :container_host, ENV['container_host']
set :container_user, ENV['container_user']

module Container
  def self.execute(cmd)
    "ssh #{fetch(:container_user)}@#{fetch(:container_host)} \"#{cmd}\""
  end
end

namespace :environment do

  desc 'Create the Environment on the container'
  task :create do
    on roles(:app) do
      execute Container.execute("envadd #{fetch(:application)} #{ENV['environment_name']} #{fetch(:repo_url)}")
    end
  end

end
