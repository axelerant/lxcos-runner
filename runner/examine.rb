require 'lxc'

#List out the number of containers irrespective to the state

def number_of_containers
  c = LXC::list_containers()
  c.count
end

number_of_containers
