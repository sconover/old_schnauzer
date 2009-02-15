require 'osx/cocoa'

OSX.require_framework 'WebKit'

class LocalProtocol < OSX::NSURLProtocol

  objc_class_method(:canInitWithRequest_, '@:@@')
  def self.canInitWithRequest(request)
    request.URL.scheme == "local" ? 0 : 1
  end
  
  objc_class_method(:canonicalRequestForRequest_, '@:@@') 
  def self.canonicalRequestForRequest(ns_url_request)
    ns_url_request
  end
  
  def startLoading
    
    response_body = "<a>hello #{request.URL.relativePath.to_s}</a>"
    
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
  
end

class LocalProtocolClient < OSX::NSObject
  CocoaUtils.setup_generic_instance_methods(
    self, [
      :URLProtocol_cachedResponseIsValid,
      :URLProtocol_didCancelAuthenticationChallenge,
      :URLProtocol_didFailWithError,
      :URLProtocol_didLoadData,
      :URLProtocol_didReceiveAuthenticationChallenge,
      :URLProtocol_didReceiveResponse_cacheStoragePolicy,
      :URLProtocol_wasRedirectedToRequest_redirectResponse,
      :URLProtocolDidFinishLoading
    ]
  )
    

end