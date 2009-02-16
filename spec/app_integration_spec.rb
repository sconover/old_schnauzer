require "rubygems"
require "fileutils"
require "lib/schnauzer"
require 'sinatra/test'
require 'spec/myapp/my_sinatra_app'
require "spec"



describe "schnauzer + sinatra app" do
  before(:all) do
    harness = Sinatra::TestHarness.new
    @browser = Schnauzer.new do |request, response|
                 harness.get(request.fullpath)
                 response.write(harness.response.body)
               end
    @harness = harness
  end
  
  after(:all) do
    Schnauzer.unload_request_handler
  end
  
  it "session works on its own (sanity check)" do
    @harness.get("/foo/hi")    
    @harness.response.body.should == "hi I'm a web app"
  end
  
  it "same thing but with schnauzer (using the session object to request)" do
    @browser.load_url("local://host/foo/hi")
    @browser.js("document.body.innerHTML").should include("hi I'm a web app")
  end
  
  it "basic ajax works" do
    @browser.load_url("local://host/ajax")
    @browser.js("document.body.innerHTML").should include("hi I do ajax")
    @browser.js("document.getElementById('ajax_button').onclick()")
    @browser.js("document.body.innerHTML").should include(%{message goes here:<div id="message">peter_rabbit, echoed back</div>})
  end

end
