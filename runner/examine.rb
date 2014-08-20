require 'lxc'
require 'chef'
require 'chef/knife'
require 'net/ssh'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'mysql',
  host: 'localhost',
  database: 'lxdb1',
  username: 'root',
  password: 'root')

class Node < ActiveRecord::Base
  #List out all the nodes
  def node_list
    Chef::Config.from_file(File.expand_path('~/.chef/knife.rb'))
    Chef::Node.list.each do |node|
      puts node.first
    containers_in_node(node.first)
    end
  end


  # Find number of containers in each node
  def containers_in_node(node_name)
    Chef::Config.from_file(File.expand_path('~/.chef/knife.rb'))
    Net::SSH.start(node_name, 'goatos') do |session|
      no_of_containers = session.exec!('number_of_containers.rb')
      puts no_of_containers
      # if number of containers is equal to 100, provision a new node. 
      provision_new_node if no_of_containers.to_i >= 100
    end
  end

  def provision_new_node
    puts "Provisioning new node"
    # Many of these can go into knife.rb file after some initial tweaking.
    aws_access_key_id = "AKIAJ5A4KW3VVHLFHJEQ" #"your-aws-access-key-id"
    aws_secret_access_key = "lzYt32p5oJb6ezk/D3OK4Xri3ZMVic5dg2A9XFr5"  #"your-aws-secret-access-key"

    #Node details
    node_name = name
    instance_size = "t1.micro"  #For initial testing later to a large instance
    ebs_root_vol_size = 30   # in GB
    region = "us-east-1b"
    ami_name = "ami-7050ae18" #Use this prebaked AMI
    security_group = "goatbase"
    run_list = "role[lxcosbase]"
    username = "ubuntu"
    aws_key_name = "medhuec2" #Key name on the runner machine
    aws_key_path = "/home/ubuntu/medhuec2.pem" #Full path of the key

    #Command to provision the instance
    provision_cmd = [
     "knife ec2 server create",
      "-r #{run_list}",
      "-I #{ami_name}",
      "--flavor #{instance_size}",
      "-G #{security_group}",
      "-Z #{region}",
      "-x #{username}",
      "-S #{aws_key_name}",
      "-N #{node_name}",
      "-i #{aws_key_path}",
      "-A #{aws_access_key_id}",
      "-K #{aws_secret_access_key}",
      "--ebs-size #{ebs_root_vol_size}"
    ].join(" ")


    # collect IP address
    ip_address = get_ip_address(provision_cmd)

    #Provision it
    status = system(provision_cmd) ? 0 : -1
    insert_node(node_name, ip_address) if status == 0
    exit status
  end

  # fetch ip adddress
  def get_ip_address(provision_cmd)
    ip_addr = nil
    IO.popen(provision_cmd) do |pipe|
      puts "Provisioning new node"
      begin
        while line = pipe.readline
          if line =~ /^Public IP Address: (.*)$/
            ip_addr = $1.strip
            break
          end
        end
      rescue EOFError => e
        puts e.message
      end
    end
    ip_addr
  end

  #def intimate_node
  #Intimate the current active node to webapp(projsapce)
  #so that ir provisions containers in that node
  #end

  # fetch random word and write remaining words back to the dictionary except for the random one.
  def name
    words = File.open("/home/ubuntu/test-runner/runner/dictionary.rb", "r").to_a
    random_word = words.sample
    words_remaining = words - [random_word]

    if words.empty?
      puts "Dictionary is empty."
    else
      dictionary = File.open("/home/ubuntu/test-runner/runner/dictionary.rb", "w")
      words_remaining.each do |word|
        dictionary.write(word)
      end
      dictionary.close
      random_word.chomp.concat(".lxcos.io")
    end
  end


  def insert_node(node_name, ip_addr)
    node = Node.create(name: node_name, ip_address: ip_addr, status: 'active')
    puts "Node #{node.name} is #{status} and it\'s IP address is #{node.ip_address}."
  end

end

Node.new.node_list
