require "rubygems"
require "spec"
require "lib/cocoa_utils"
require "lib/local_protocol"
require "pp"

describe LocalProtocol do
  it "loads resources locally" do
    OSX::NSURLProtocol.registerClass(LocalProtocol)
    LocalProtocol.request_handler = proc do |url_path|
      "<a>hello #{url_path}</a>"
    end
    
    CocoaUtils.url_get("local://local/fooZZZ").should == "<a>hello /fooZZZ</a>"
  end
end