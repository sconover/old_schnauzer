require "rubygems"
require "benchmark"
require "lib/schnauzer"
require 'sinatra/test'
require "spec"



describe "schnauzer + sinatra app" do
  before(:all) do
    app = 
      Sinatra.new do
        set :static, true
        set :public, "spec/myapp/public"
        
        get '/foo/hi' do
          "hi I'm a web app"
        end

        get '/echo/:to_echo' do
          "#{params[:to_echo]}, echoed back"
        end


        get '/ajax' do
          (<<-HTML)
            <html>
              <head>
                <script type="text/javascript" language="JavaScript" src="/prototype.js"></script>
                <script type="text/javascript">
                  function doEcho(str) {
                    $('message').innerHTML = "echoing " + str
                    new Ajax.Request(
                        "/echo/" + str,
                        {method: 'get',
                         onComplete: function(result){document.getElementById("message").innerHTML = result.responseText},
                         onFailure: function(){document.getElementById("message").innerHTML = "failed"}}
                    )
                  }
                </script>
        
              </head>
              <body>
                hi I do ajax
                <button id="ajax_button" onclick="doEcho('peter_rabbit')">click me to do ajax</button>
                message goes here:<div id="message"></div>
              </body>
            </html>
          HTML
        end
      end
    
    harness = Sinatra::TestHarness.new(app)
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

    @browser.js("doEcho('flopsy')")
    @browser.js("document.body.innerHTML").should include(%{message goes here:<div id="message">flopsy, echoed back</div>})
  end
  
  xit "ajax page performance" do
    n = 20
    time = 
      Benchmark.realtime {
        n.times do
          @browser.load_url("local://host/main/page")
          @browser.js("document.getElementById('ajax_button').onclick()")
        end
      }
    puts "ajax, complex: #{n} requests in #{time}s  #{(time*1000)/n}ms/r  #{n.to_f/time.to_f}r/s"
  end
end
