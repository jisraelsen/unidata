if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'rspec'
require 'time'
require 'unidata'

def package_local_constructor klass,*values
  constructors = klass.java_class.declared_constructors
  constructors.each do |c|
    c.accessible = true
    begin
      return c.new_instance(*values).to_java
    rescue TypeError
      false
    end
  end
  raise TypeError,"found no matching constructor for " + klass.to_s + "(" + value.class + ")"
end

class StubUniSelectList
  def initialize(items)
    @items = items.map{|item| item.to_s}
  end

  def next
    @items.shift || ""
  end
end

RSpec.configure do |config|
end
