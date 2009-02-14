require 'osx/cocoa'

OSX.require_framework 'WebKit'

class LocalProtocol < OSX::NSURLProtocol

  objc_class_method(:canInitWithRequest_, '@:@@')
  def self.canInitWithRequest(ns_url_request)
    p" canInitWithRequest"
    0.to_ns
  end
  
  objc_class_method(:canonicalRequestForRequest_, '@:@@') 
  def self.canonicalRequestForRequest(ns_url_request)
    p"canonicalRequestForRequest #{ns_url_request.inspect}"
    ns_url_request
  end
  
  def startLoading
    p "startLoading"
    p args
    
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