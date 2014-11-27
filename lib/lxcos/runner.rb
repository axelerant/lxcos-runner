require "lxcos/runner/version"

module Lxcos
  module Runner
    require 'lxc'
    require 'chef'
    require 'chef/knife'
    require 'net/ssh'
    @config = {}

    def self.chef_config_file(file_name)
      Chef::Config.from_file(File.expand_path(file_name))
    end
  end
end


#chef_config
Lxcos::Runner.chef_config_file("~/.chef/knife.rb");

#provision
require "lxcos/runner/provision/node.rb"
require "lxcos/runner/provision/container.rb"

#deploy
require "lxcos/runner/deploy/task_runner.rb"
require "lxcos/runner/deploy/environment.rb"
require "lxcos/runner/deploy/code.rb"
require "lxcos/runner/deploy/database.rb"
require "lxcos/runner/deploy/files.rb"
