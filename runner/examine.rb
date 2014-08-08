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

def provision_new_node
  # Many of these can go into knife.rb file after some initial tweaking.
  AWS_ACCESS_KEY_ID     = "your-aws-access-key-id"
  AWS_SECRET_ACCESS_KEY = "your-aws-secret-access-key"

  # Node details
  NODE_NAME         = "node1.example.com" //Choose from a dictionary of pre defined hostnames
  INSTANCE_SIZE     = "t1.micro"  //For initial testing later to a large instance
  EBS_ROOT_VOL_SIZE = 30   # in GB
  REGION            = "us-east-1b"
  AMI_NAME          = "ami-7050ae18" //Use this prebaked AMI
  SECURITY_GROUP    = "goatbase"
  RUN_LIST          = "role[lxcosbase]"
  USERNAME          = "ubuntu"
  AWS_KEY_NAME	  = "medhuec2" //Key name on the runner machine
  AWS_KEY_PATH	  = "medhuec2.pem" //Full path of the key

  #Command to provision the instance
  provision_cmd = [
    "knife ec2 server create",
    "-r #{RUN_LIST}",
    "-I #{AMI_NAME}",
    "--flavor #{INSTANCE_SIZE}",
    "-G #{SECURITY_GROUP}",
    "-Z #{REGION}",
    "-x #{USERNAME}",
    "-S #{AWS_KEY_NAME}",
    "-i #{AWS_KEY_PATH}",
    "-K #{AWS_ACCESS_KEY_ID}",
    "-A #{AWS_SECRET_ACCESS_KEY}",
    "--ebs-size #{EBS_ROOT_VOL_SIZE}"
  ].join(" ")

  #Provision it

  status = system(provision_cmd) ? 0 : -1
  exit status
end

#def intimate_node
#Intimate the current active node to webapp(projsapce)
#so that ir provisions containers in that node
#end

