require 'osx/cocoa'

OSX.require_framework 'WebKit'

class LocalProtocol < OSX::NSURLProtocol

  objc_class_method(:canInitWithRequest_, '@:@@')
  def self.canInitWithRequest(ns_url_request)
    p" canInitWithRequest"
    0
  end
  
  objc_class_method(:canonicalRequestForRequest_, '@:@@') 
  def self.canonicalRequestForRequest(ns_url_request)
    p"canonicalRequestForRequest #{ns_url_request.inspect}"
    CocoaUtils.describe(ns_url_request)
    ns_url_request
  end
  
  def startLoading
    p "startLoading"
    CocoaUtils.describe(self.client)
    
    response = OSX::NSURLResponse \
                .alloc \
                .initWithURL_MIMEType_expectedContentLength_textEncodingName(
                  request.URL,
                  "text/html".to_ns,
                  0,
                  nil
                )
    
    self.client.URLProtocol_didReceiveResponse_cacheStoragePolicy(self, response, nil)
    self.client.URLProtocolDidFinishLoading(self)
    response.release
      # 
      #         /* create the response record, set the mime type to jpeg */
      # NSURLResponse *response = 
      #   [[NSURLResponse alloc] initWithURL:[request URL] 
      #     MIMEType:@"image/jpeg" 
      #     expectedContentLength:-1 
      #     textEncodingName:nil];
      # 
      #   /* get a reference to the client so we can hand off the data */
      #     id<NSURLProtocolClient> client = [self client];
      # 
      #   /* turn off caching for this response data */ 
      # [client URLProtocol:self didReceiveResponse:response
      #     cacheStoragePolicy:NSURLCacheStorageNotAllowed];
      # 
      #   /* set the data in the response to our jfif data */ 
      # [client URLProtocol:self didLoadData:data];
      # 
      #   /* notify that we completed loading */
      # [client URLProtocolDidFinishLoading:self];
      # 
      #   /* we can release our copy */
      # [response release];
      #   
    
    
    
    
    
    
    
    
    
  end
  
  def stopLoading
    p "stopLoading"
    # p self.request
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