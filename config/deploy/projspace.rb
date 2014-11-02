server ENV['server_host'], user: ENV['server_user'], roles: %w{web app}, password: ENV['password']
set :container_host, ENV['container_host']
set :container_user, ENV['container_user']

role :container, "#{fetch(:container_user)}@#{fetch(:container_host)}"

namespace :environment do

  desc 'Create the Environment on the container'
  task :create => [] do
    on roles(:app) do
      execute 'whoami'
      on roles(:container) do
        execute 'hostname'
      end
    end
  end

end
