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
      execute Container.execute("sudo envadd #{fetch(:application)} #{ENV['environment_name']}")

      execute "proxy_direct -c #{fetch(:application)} -e #{ENV['environment_name']} -i #{ENV['container_host']} -n #{ENV['node_name']}"
    end

    #this is lame
    Net::SSH.start(ENV['server_host'], 'ubuntu') do |session|
      session.exec!("sudo cp /opt/goatos/.local/share/lxc/#{fetch(:application)}/#{fetch(:application)}.#{ENV['environment_name']}.#{ENV['node_name']}.lxcos.io.conf /etc/apache2/sites-available/")

      session.exec!("sudo a2ensite #{fetch(:application)}.#{ENV['environment_name']}.#{ENV['node_name']}.lxcos.io.conf && sudo /etc/init.d/apache2 reload")
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
      execute Container.execute("mysqldump -u #{ENV['source_db_user']} -p#{ENV['source_db_password']} #{ENV['source_db_name']} |  tee /home/#{ENV['project_name']}/dbdumps/#{ENV['source_db_name']}to#{ENV['destination_db_name']}.sql > /dev/null && mysql -u #{ENV['destination_db_user']} -p#{ENV['destination_db_password']} #{ENV['destination_db_name']} < /home/#{ENV['project_name']}/dbdumps/#{ENV['source_db_name']}to#{ENV['destination_db_name']}.sql")
    end
  end

  desc 'Sync DB for the environment'
  task :sync_files do
    on roles(:app) do
      execute Container.execute("rsync -auz /home/#{ENV['project_name']}/files/#{ENV['source_env_name']}/* /home/${project}/files/#{ENV['destination_env_name']}/")
    end
  end

  desc 'Lock site for the environment'
  task :lock_site do
    on roles(:app) do
      execute Container.execute("sudo a2dissite #{ENV['project_name']}.#{ENV['environment_name']}.projspace.com.conf && sudo a2ensite locked.#{ENV['project_name']}.#{ENV['environment_name']}.projspace.com.conf && sudo /etc/init.d/apache2 reload")
    end  
  end 

  desc 'Unlock site for the environment'
  task :unlock_site do
    on roles(:app) do
      execute Container.execute("sudo a2dissite locked.#{ENV['project_name']}.#{ENV['environment_name']}.projspace.com.conf && sudo a2ensite #{ENV['project_name']}.#{ENV['environment_name']}.projspace.com.conf && sudo /etc/init.d/apache2 reload")
    end  
  end 

end
