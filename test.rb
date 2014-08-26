require '~/Workspace/lxcos-runner/test1.rb'

module A
  class Student
    attr_accessor :name

    def initialize(name)
      @name = name
    end  

    def print_name
      puts @name
      B.football
    end

    def self.good_boy
      puts "Good boy"
    end
  end
end

A::Student.new('tapan').print_name
A::Student.good_boy

