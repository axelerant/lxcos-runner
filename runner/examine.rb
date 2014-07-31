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

#def run_in_all_nodes
#  Chef::Config.from_file(File.expand_path('~/.chef/knife.rb'))
#  Chef::Knife.run(%w(ssh 'name:*' -x ubuntu -i /path/to/key "run_number_of_containers")
#end

#def provision_new_node
#Logic to see the number of containers and provision new node if >100
#end

#def intimate_node
#Intimate the current active node to webapp(projsapce)
#so that ir provisions containers in that node
#end

