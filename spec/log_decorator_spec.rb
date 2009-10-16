require "rubygems"
require "test/spec"
require "lib/log_decorator"

describe LogDecorator, "decorate an object" do
  it "logs invocations" do
    calls = []
    
    my_array = []
    
    stream = StringIO.new("", "w+")
    
    LogDecorator.new(stream).apply_to(my_array)
    
    my_array.push("a")
    my_array.pop.should == "a"
    
    stream.string.split("\n").should == [
      "-> Array.push(String)",
      "<- Array.push(String) : [\"a\"]",
      "-> Array.pop",
      "<- Array.pop : \"a\""
    ]
  end
  
end