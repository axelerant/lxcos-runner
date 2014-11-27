server ENV['server_host'], user: ENV['server_user'], roles: %w{web app}, password: ENV['password']
set :container_host, ENV['container_host']
set :container_user, ENV['container_user']

module Container
  def self.execute(cmd)
    "ssh -o StrictHostKeyChecking=no -t -A #{fetch(:container_user)}@#{fetch(:container_host)} \"#{cmd}\""
  end
end

namespace :environment do

  desc 'Create the Environment on the container'
  task :create do
    on roles(:app) do
      execute Container.execute("sudo envadd #{fetch(:application)} #{ENV['environment_name']} #{fetch(:repo_url)}")
    end
  end

  desc 'Deploy code for the environment'
  task :deploy_code do
    on roles(:app) do
      execute Container.execute("sudo rm /home/#{ENV['project_name']}/www/#{ENV['environment_name']}/{*,.??*} -rf && sudo -u www-data git clone #{fetch(:repo_url)} /home/#{ENV['project_name']}/www/#{ENV['environment_name']}/ && cd /home/#{ENV['project_name']}/www/#{ENV['environment_name']}/ && sudo -u www-data git config core.sharedRepository true && cd /home/#{ENV['project_name']}/www/#{ENV['environment_name']}/ && sudo -u www-data git checkout #{ENV['repo_branch']} && sudo -u www-data ln -s /home/#{ENV['project_name']}/files/#{ENV['environment_name']} /home/#{ENV['project_name']}/www/#{ENV['environment_name']}/docroot/#{ENV['files_path']} && sudo -u www-data sh /home/#{ENV['project_name']}/www/#{ENV['environment_name']}/projspace-utils/#{ENV['environment_name']}-postDeployHook")
    end
  end

  desc 'Sync DB for the environment'
  task :sync_database do
    on roles(:app) do

    end
  end

  desc 'Sync DB for the environment'
  task :sync_files do
    on roles(:app) do

    end
  end


end
