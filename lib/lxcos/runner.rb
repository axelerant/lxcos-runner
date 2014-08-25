require "lxcos/runner/version"

module Lxcos
  module Runner
    @config = {}

    def self.chef_config_file(file_name)
      Chef::Config.from_file(File.expand_path(file_name))
    end


  end
end


#chef_config


require "lxcos/runner/node"
require "lxcos/runner/container"
