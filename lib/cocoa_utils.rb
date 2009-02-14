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
    response = OSX::NSURLConnection.sendSynchronousRequest_returningResponse_error(url_request, url_response, nil)
    str = "." * response.length
    response.getBytes_length(str)
    str
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