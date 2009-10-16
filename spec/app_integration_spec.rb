require "rubygems"
require "benchmark"
require "lib/schnauzer"
require 'sinatra/test'
require "test/spec"



describe "schnauzer + sinatra app" do
  before do
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

        post '/echo_standard_post' do
          (<<-HTML)
            <html>
              <body>
                <div id="message">You posted #{params[:to_echo]}</div>
              </body>
            </html>
          HTML
        end

        post '/echo_post' do
          "#{params[:to_echo]}, post echoed back"
        end

        get '/html_post' do
          (<<-HTML)
            <html>
              <body>
                hi I do standard post
                <form id="the_form" method="post" action="/echo_standard_post">
                  <input id='message_to_post' type="hidden" name="to_echo" value=""/>
                  <input type="submit"/>
                </form>
              </body>
            </html>
          HTML
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
        
        get '/ajax_post' do
          (<<-HTML)
            <html>
              <head>
                <script type="text/javascript" language="JavaScript" src="/prototype.js"></script>
                <script type="text/javascript">
                  function doEchoPost(str) {
                    $('message').innerHTML = "echoing " + str
                    new Ajax.Request(
                        "/echo_post",
                        {method: 'post',
                         postBody: str,
                         onComplete: function(result){document.getElementById("message").innerHTML = result.responseText},
                         onFailure: function(){document.getElementById("message").innerHTML = "failed"}}
                    )
                  }
                </script>
        
              </head>
              <body>
                hi I do ajax post
                <button id="ajax_button" onclick="doEchoPost('peter_rabbit')">click me to do ajax</button>
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
  
  after do
    Schnauzer.unload_request_handler
  end
  
  it "session works on its own (sanity check)" do
    @harness.get("/foo/hi")    
    @harness.response.body.should == "hi I'm a web app"
  end
  
  it "same thing but with schnauzer (using the session object to request)" do
    @browser.load_url("local://host/foo/hi")
    @browser.js("document.body.innerHTML").should.include("hi I'm a web app")
  end
  
  it "basic ajax works" do
    @browser.load_url("local://host/ajax")
    @browser.js("document.body.innerHTML").should.include("hi I do ajax")
    
    @browser.js("document.getElementById('ajax_button').onclick()")
    @browser.js("document.body.innerHTML").should.include(%{message goes here:<div id="message">peter_rabbit, echoed back</div>})

    @browser.js("doEcho('flopsy')")
    @browser.js("document.body.innerHTML").should.include(%{message goes here:<div id="message">flopsy, echoed back</div>})
  end
  
  xit "standard post" do
    @browser.load_url("local://host/html_post")
    
    @browser.js("document.getElementById('message_to_post').value = 'Peter Rabbit'")
    @browser.js("document.getElementById('the_form').submit()")
    
    @browser.js("document.body.innerHTML").should.include("You posted Peter Rabbit")
  end
  
    
  xit "ajax post works" do
    @browser.load_url("local://host/ajax_post")
    @browser.js("document.body.innerHTML").should.include("hi I do ajax")
    
    @browser.js("document.getElementById('ajax_button').onclick()")
    @browser.js("document.body.innerHTML").should.include(%{message goes here:<div id="message">peter_rabbit, post echoed back</div>})
    
    # @browser.js("doEchoPost('flopsy')")
    # @browser.js("document.body.innerHTML").should.include(%{message goes here:<div id="message">flopsy, post echoed back</div>})
  end
  
  it "ajax page performance" do
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
