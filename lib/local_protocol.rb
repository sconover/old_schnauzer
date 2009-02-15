require 'osx/cocoa'

OSX.require_framework 'WebKit'

class LocalProtocol < OSX::NSURLProtocol

  objc_class_method(:canInitWithRequest_, '@:@@')
  def self.canInitWithRequest(request)
    0
  end
  
  objc_class_method(:canonicalRequestForRequest_, '@:@@') 
  def self.canonicalRequestForRequest(request)
    request
  end
  
  def self.request_handler=(block)
    @@request_handler = block
  end
  
  def startLoading
    response_body = @@request_handler.call(request.URL.relativePath.to_s)
    
    response = OSX::NSURLResponse \
                .alloc \
                .initWithURL_MIMEType_expectedContentLength_textEncodingName(
                  request.URL,
                  "text/html".to_ns,
                  response_body.length,
                  nil
                )
    
    self.client.URLProtocol_didReceiveResponse_cacheStoragePolicy(self, response, nil)
    data = OSX::NSData.alloc.initWithBytes_length(response_body)
    self.client.URLProtocol_didLoadData(self, data)
    self.client.URLProtocolDidFinishLoading(self)
    response.release
  end
  
  def stopLoading
    # p "stopLoading"
  end
  
  # def method_missing(name_sym, *args)
  #   p name_sym
  #   self.objc_send(name_sym, args)
  # end
  
end