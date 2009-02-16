require "rubygems"
require "lib/schnauzer"
require "benchmark"
require "spec"

describe Schnauzer do
  it "loads urls my way" do
    browser = Schnauzer.new do |request, response|
      response.write(
        (<<-HTML)
          <html>
            <body>
            	<i>hello #{request.fullpath}</i>
            </body>
          </html>
        HTML
      )
    end
    
    browser.load_url("local://host/custom/page")
    
    browser.js("document.body.innerHTML").should include("<i>hello /custom/page</i>")
  end

  it "url references within documents get loaded my way too" do
    browser = Schnauzer.new do |request, response|
      html =
        if request.fullpath == "/main/page"
          (<<-HTML)
            <html>
              <link rel="stylesheet" type="text/css" href="/some.css"/>
            

              <body>
              	<i>hello #{request.fullpath}</i>
              	<div id="spot"></div>
              </body>
            
              <script type="text/javascript" language="JavaScript" src="/some.js"></script>
            </html>
          HTML
        elsif request.fullpath == "/some.css"
          %{
            body {
              margin: 23px;
            }
          }
        elsif request.fullpath == "/some.js"
          %{
            document.getElementById("spot").innerHTML = "john jay"
          }
        end
      response.write(html)
    end
    
    browser.load_url("local://host/main/page")
    
    browser.js("document.body.innerHTML").should include("<i>hello /main/page</i>")
    browser.js("document.body.innerHTML").should include("<div id=\"spot\">john jay</div>")
    browser.js("window.getComputedStyle(document.body, null).marginLeft").should == "23px"
  end

    
  it "performance" do
    browser = Schnauzer.new do |request, response|
      (<<-HTML)
        <html>
          <body>
          	<i>hello #{request.fullpath}</i>
          </body>
        </html>
      HTML
    end
    
    n = 100
    time = 
      Benchmark.realtime {
        n.times do
          browser.load_url("local://host/main/page")
        end
      }
    puts "custom url loader, simple: #{n} requests in #{time}s  #{(time*1000)/n}ms/r  #{n.to_f/time.to_f}r/s"



    browser = Schnauzer.new do |request, response|
      html =
        if request.fullpath == "/main/page"
          (<<-HTML)
            <html>
              <link rel="stylesheet" type="text/css" href="/some.css"/>
            

              <body>
              	<i>hello #{request.fullpath}</i>
              	<div id="spot"></div>
              </body>
            
              <script type="text/javascript" language="JavaScript" src="/some.js"></script>
            </html>
          HTML
        elsif request.fullpath == "/some.css"
          %{
            body {
              margin: 23px;
            }
          }
        elsif request.fullpath == "/some.js"
          %{
            document.getElementById("spot").innerHTML = "john jay"
          }
        end
      response.write(html)
    end
    
    n = 100
    time = 
      Benchmark.realtime {
        n.times do
          browser.load_url("local://host/main/page")
        end
      }
    puts "custom url loader, complex: #{n} requests in #{time}s  #{(time*1000)/n}ms/r  #{n.to_f/time.to_f}r/s"
  end
end