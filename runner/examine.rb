require 'lxc'
require 'chef'
require 'chef/knife'

#List out all the nodes
def node_list
  Chef::Config.from_file(File.expand_path('~/.chef/knife.rb'))
  Chef::Node.list.each do |node|
	puts node.first
  end
end

#List out the number of containers irrespective to the state

def number_of_containers
  c = LXC::list_containers()
  c.count
end

