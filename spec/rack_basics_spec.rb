require "rubygems"
require "lib/schnauzer"
require "spec"

describe "schnauzer + sinatra app" do
  before(:all) do
    @request = nil
    @response = nil
    
    @browser = Schnauzer.new do |request, response|
                 @request = request
                 @response = response
               end
  end
  
  after(:all) do
    Schnauzer.unload_request_handler
  end
  
  it "write to the response" do
    browser = Schnauzer.new do |request, response|
                response.write("this is a rack-compliant response.write")
              end
    
    browser.load_url("local://host/foo")
    browser.js("document.body.innerHTML").should include("this is a rack-compliant response.write")
  end
  
    
    
  
end