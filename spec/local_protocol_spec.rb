require "rubygems"
require "spec"
require "lib/cocoa_utils"
require "lib/local_protocol"
require "pp"

describe LocalProtocol do
  before do
    OSX::NSURLProtocol.registerClass(LocalProtocol)
  end
  
  after do
    OSX::NSURLProtocol.unregisterClass(LocalProtocol)
  end
  
  describe "basics" do
    it "loads resources locally" do
    
      LocalProtocol.request_handler = proc do |request, response|
        response.write("<a>hello #{request.fullpath}</a>")
      end
    
      CocoaUtils.url_get("local://local/fooZZZ").body.should == "<a>hello /fooZZZ</a>"
      CocoaUtils.url_get("local://local/foo?a=b").body.should == "<a>hello /foo?a=b</a>"
    end
  end
  
  
  describe "rack" do
    it "request url" do
      LocalProtocol.request_handler = proc do |request, response|
        request.request_method.should == "GET"
        request.scheme.should == "local"
        request.host.should == "myhost"
        request.port.should == 80
        request.path_info.should == "/foo"
        request.query_string.should == "a=b"
        request.url.should == "local://myhost/foo?a=b"
      end
      
      CocoaUtils.url_get("local://myhost/foo?a=b")
    end

    it "request url 2" do
      LocalProtocol.request_handler = proc do |request, response|
        request.request_method.should == "GET"
        request.scheme.should == "http"
        request.host.should == "myhost"
        request.port.should == 3333
        request.path_info.should == ""
        request.query_string.should == ""
        request.url.should == "http://myhost:3333"
      end
      
      CocoaUtils.url_get("http://myhost:3333")
    end

    
    it "writes" do
      LocalProtocol.request_handler = proc do |request, response|
        response.write("basic response")
        response.write("...another part")
      end
      
      CocoaUtils.url_get("local://host/foo").body.should == "basic response...another part"
    end
    
    it "response content-type" do
      LocalProtocol.request_handler = proc do |request, response|
        response.header["Content-Type"] = "application/json"
        response.write("rabbit")
      end
      
      CocoaUtils.url_get("local://host/foo").body.should == "rabbit"
      CocoaUtils.url_get("local://host/foo").response.MIMEType.to_s.should == "application/json"
    end
    
    
  end
  
end