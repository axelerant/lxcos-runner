# config valid only for Capistrano 3.1
lock '3.2.1'

set :pty, true
set :deploy_config_path, Dir.getwd + "/config/deploy.rb"
set :stage_config_path, Dir.getwd + "/config/deploy"
