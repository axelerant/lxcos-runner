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

require "lxcos/runner/node"
require "lxcos/runner/container"

