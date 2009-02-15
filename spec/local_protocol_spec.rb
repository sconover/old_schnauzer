require "rubygems"
require "spec"
require "lib/cocoa_utils"
require "lib/local_protocol"
require "pp"

describe LocalProtocol do
  it "loads resources locally" do

    
    
    # protocol = LocalProtocol.new(proc {|request| "<a>hello</a>" })
    # CocoaUtils.describe(LocalProtocol)
    # protocol = LocalProtocol.alloc
    # CocoaUtils.describe(protocol)
    # p protocol.request
    # protocol.startLoading
    
    # CocoaUtils.describe(protocol)
    
    OSX::NSURLProtocol.registerClass(LocalProtocol)
    
    CocoaUtils.url_get("file://foo").should == "<a>hello</a>"
  end
end