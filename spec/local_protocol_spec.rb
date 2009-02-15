require "rubygems"
require "spec"
require "lib/cocoa_utils"
require "lib/local_protocol"
require "pp"

describe LocalProtocol do
  before(:all) do
    OSX::NSURLProtocol.registerClass(LocalProtocol)
  end
  
  after(:all) do
    OSX::NSURLProtocol.unregisterClass(LocalProtocol)
  end
  
  it "loads resources locally" do
    
    LocalProtocol.request_handler = proc do |url_path|
      "<a>hello #{url_path}</a>"
    end
    
    CocoaUtils.url_get("local://local/fooZZZ").should == "<a>hello /fooZZZ</a>"
  end
end