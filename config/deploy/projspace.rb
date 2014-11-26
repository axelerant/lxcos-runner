server ENV['server_host'], user: ENV['server_user'], roles: %w{web app}, password: ENV['password']
set :container_host, ENV['container_host']
set :container_user, ENV['container_user']

module Container
  def self.execute(cmd)
    "ssh -o StrictHostKeyChecking=no #{fetch(:container_user)}@#{fetch(:container_host)} \"#{cmd}\""
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
      execute Container.execute("sudo rm /home/#{fetch(:project_name)}/www/#{fetch(:environment_name)}/{*,.??*} -rf && sudo -u www-data git clone #{fetch(:repo_url)} /home/#{fetch(:project_name)}/www/#{fetch(:environment_name)}/ && cd /home/#{fetch(:project_name)}/www/#{fetch(:environment_name)}/ && sudo -u www-data git config core.sharedRepository true && cd /home/#{fetch(:project_name)}/www/#{fetch(:environment_name)}/ && sudo -u www-data git checkout #{fetch(:repo_branch)} && sudo -u www-data ln -s /home/#{fetch(:project_name)}/files/#{fetch(:environment_name)} /home/#{fetch(:project_name)}/www/#{fetch(:environment_name)}/docroot/#{fetch(:files_path)} && sudo -u www-data sh /home/#{fetch(:project_name)}/www/#{fetch(:environment_name)}/projspace-utils/#{fetch(:environment_name)}-postDeployHook")
    end
  end


end
