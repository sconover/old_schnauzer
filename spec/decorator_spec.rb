require "rubygems"
require "test/spec"
require "lib/decorator"

describe "decorate an object" do
  it "surrounds methods, invokes 'before'" do
    calls = []
    
    decorator = Decorator.new
    decorator.before do |method_symbol, args|
      calls << method_symbol
    end
    
    my_array = []
    decorator.apply_to(my_array)
    
    my_array.push("a")
    my_array.pop.should == "a"
    
    calls.should == [:push, :pop]
  end
  
  it "doesn't interfere with other instances of the same class" do
    calls = []
    
    decorator = Decorator.new
    decorator.before do |method_symbol, args|
      calls << method_symbol
    end
    
    my_array = []
    decorator.apply_to(my_array)
    
    your_array = []
    
    my_array.push("a")
    my_array.pop.should == "a"
    my_array.uniq
    
    your_array.push("zz")
    your_array.pop.should == "zz"
    your_array.sort!
    
    calls.should == [:push, :pop, :uniq]
  end
  
  it "surrounds methods, invokes 'after'" do
    calls = []
    
    decorator = Decorator.new
    decorator.after do |method_symbol, args, result|
      calls << result
    end
    
    my_array = []
    decorator.apply_to(my_array)
    
    my_array.push("a")
    my_array.pop.should == "a"
    
    calls[0].should == []
    calls[1].should == "a"
  end

  it "don't decorate .inspect" do
    calls = []
    
    decorator = Decorator.new
    decorator.before do |method_symbol, args|
      calls << method_symbol
    end
    
    my_array = []
    decorator.apply_to(my_array)
    
    my_array.push("a")
    my_array.pop.should == "a"
    my_array.inspect
    
    calls.should == [:push, :pop]
  end

end