require "pp"
require 'osx/cocoa'

class CocoaUtils
  def self.describe(object)
    pp (object.objc_methods.sort - OSX::NSObject.alloc.objc_methods.sort)
  end
  
  def self.url_get(url_str)
    url = OSX::NSURL.alloc.initWithString(url_str)
    url_request = OSX::NSURLRequest.requestWithURL(url)
    url_response = OSX::NSURLResponse.alloc
    
    
    conn = 
      OSX::NSURLConnection.connectionWithRequest_delegate(
        url_request, 
        ConnectionDelegate.alloc.init
      )
    
    CocoaUtils.describe(conn)
    
    OSX.CFRunLoopRun
    # conn.start
    # conn.start
    # response = OSX::NSURLConnection.sendSynchronousRequest_returningResponse_error(url_request, url_response, nil)
    # str = "." * response.length
    # response.getBytes_length(str)
    # str
    "foo"
  end
  
  def self.setup_generic_instance_methods(klass, objc_methods_symbols)
    
    objc_methods_symbols.each do |objc_method_symbol|
      klass.objc_method(objc_method_symbol)
      klass.instance_eval(%{
        def #{objc_method_symbol.to_s}_(*args)
          puts "#{objc_method_symbol.to_s}"
          p args
        end
      })
    end
    
  end
end

class ConnectionDelegate < OSX::NSObject
  def connection_didFailWithError
    puts "hi"
  end
  
  def connection_didCancelAuthenticationChallenge
    p 1
  end
  
  def connection_didReceiveAuthenticationChallenge
    p 2
  end  
    

  def connection_willCacheResponse
    p 3
  end
  
  def connection_didReceiveResponse(*args)
    p args
    p 4
  end
  
  def connection_didReceiveData
    p 5
  end
  
  def connection_willSendRequest_redirectResponse
    p 6
  end
  
  def connection_didFailWithError
    p 7
  end
  
  def connection_didFinishLoading
    p 8
  end
  
  def connectionDidFinishLoading(*args)
    p args
    p 9
    OSX.CFRunLoopStop(OSX.CFRunLoopGetCurrent)
  end
  
  # def method_missing(method, *args)
  #   p "mm=#{method} #{args.inspect}"
  # end
end