require "pp"
require 'osx/cocoa'

class CocoaUtils
  def self.describe(object)
    pp (object.objc_methods.sort - OSX::NSObject.alloc.objc_methods.sort)
  end
  
  def self.url_get(url_str)
    begin
      url = OSX::NSURL.alloc.initWithString(url_str)
      url_request = OSX::NSMutableURLRequest.requestWithURL(url)
    
      delegate = ConnectionDelegate.alloc
      conn = 
        OSX::NSURLConnection.connectionWithRequest_delegate(
          url_request, 
          delegate
        )
    
      OSX.CFRunLoopRun
      delegate
    ensure
      OSX.CFRunLoopStop(OSX.CFRunLoopGetCurrent)
    end
  end
end

class ConnectionDelegate < OSX::NSObject
  attr_reader :body, :response, :connection
  
  def connection_willCacheResponse(*args)
  end
  
  def connection_didReceiveResponse(connection, response)
    @connection = connection
    @response = response
  end
  
  def connection_didReceiveData(connection, data)
    @body = data.rubyString
  end
  
  def connectionDidFinishLoading(*args)
    OSX.CFRunLoopStop(OSX.CFRunLoopGetCurrent)
  end
end