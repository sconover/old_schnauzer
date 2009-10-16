require "rack"
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
    @@block = block
  end
  
  def startLoading
    rack_response = CocoaToRackResponseAdapter.new(request, self)

    @@block.call(
      CocoaToRackRequestAdapter.new(request), 
      rack_response
    )
    
    rack_response.send_via_cocoa
  end
  
  def stopLoading
    # p "stopLoading"
  end
  
end

    # def body;            @env["rack.input"]                       end
    #  def scheme;          @env["rack.url_scheme"]                  end
    #  def script_name;     @env["SCRIPT_NAME"].to_s                 end
    #  def path_info;       @env["PATH_INFO"].to_s                   end
    #  def port;            @env["SERVER_PORT"].to_i                 end
    #  def request_method;  @env["REQUEST_METHOD"]                   end
    #  def query_string;    @env["QUERY_STRING"].to_s                end
    #  def content_length;  @env['CONTENT_LENGTH']                   end
    #  def content_type;    @env['CONTENT_TYPE']                     end
    
class CocoaToRackRequestAdapter < Rack::Request
  def initialize(ns_url_request)
    @ns_url_request = ns_url_request
    
    env = {}
    ns_url_request.allHTTPHeaderFields.to_hash.each do |k,v|
      env[k.to_s.upcase] = v.to_s
    end
    
    env["REQUEST_METHOD"] ||= ns_url_request.HTTPMethod.to_s
    env["HTTP_HOST"] ||= ns_url_request.URL.host.to_s
    env["SERVER_PORT"] ||= (ns_url_request.URL.port.to_s.to_i > 0 ?
                             ns_url_request.URL.port.to_s.to_i :
                             80).to_s
    env["PATH_INFO"] ||= ns_url_request.URL.path.to_s
    env["QUERY_STRING"] ||= ns_url_request.URL.query.to_s
    env["rack.url_scheme"] = ns_url_request.URL.scheme.to_s

    super(env)
  end
  
  # def user_agent
  #   @env['HTTP_USER_AGENT']
  # end
  # 
  # def accept
  #   @env['HTTP_ACCEPT'].split(',').map { |a| a.strip }
  # end
  # 
  # # Override Rack 0.9.x's #params implementation (see #72 in lighthouse)
  # def params
  #   self.GET.update(self.POST)
  # rescue EOFError => boom
  #   self.GET
  # end
end

class CocoaToRackResponseAdapter < Rack::Response
  def initialize(ns_url_request, ns_url_protocol)
    super()
    @ns_url_request = ns_url_request
    @ns_url_protocol = ns_url_protocol
    # @status, @body = 200, []
    # @header = Rack::Utils::HeaderHash.new({'Content-Type' => 'text/html'})
  end
  
  def send_via_cocoa
    ns_url_response = OSX::NSHTTPURLResponse.alloc
    
    ns_url_response.initWithURL_MIMEType_expectedContentLength_textEncodingName(
      @ns_url_request.URL,
      header["Content-Type"].to_ns,
      self.header["Content-Length"].to_i,
      nil
    )
    
    @ns_url_protocol.client.URLProtocol_didReceiveResponse_cacheStoragePolicy(
      self, 
      ns_url_response, 
      nil
    )
    data = OSX::NSData.alloc.initWithBytes_length(body.join)
    @ns_url_protocol.client.URLProtocol_didLoadData(self, data)
    @ns_url_protocol.client.URLProtocolDidFinishLoading(self)
    ns_url_response.release

  end

end