require "rubygems"
require "lib/schnauzer"
require "benchmark"
require "test/spec"

describe Schnauzer do
  before do
    @browser = Schnauzer.new
  end
  
  it "loads and displays html" do
    @browser.load_html(
      (<<-HTML)
      <html>
        <body>
        	<i>hello world</i>
        </body>
      </html>
      HTML
    )

    @browser.js("document.body.innerHTML").should.include("<i>hello world</i>")
  end
  
  it "uses base url provided to make absolute urls" do
    @browser.load_html(%{
      <html>
        <body>
        	<a id="mylink" href="/mypage.html">linky</a>
        </body>
      </html>}, 
      "http://bar")
    
    
    @browser.js("document.getElementById('mylink').href").should.equal "http://bar/mypage.html"
  end
  
  it "executes javascript" do
    @browser.load_html(
      (<<-HTML)
      <html>
        <body>
        	hello <div id="the_spot"></div>
        	
        	<script type="text/javascript">
          	document.getElementById('the_spot').innerHTML='world'
        	</script>
        </body>
      </html>
      HTML
    )
    
    @browser.js("document.body.innerHTML") \
      .should.include(%{hello <div id="the_spot">world</div>})
  end
  
  it "load from url" do
    @browser.load_url("file://#{File.expand_path("spec/little_page.html")}")
    @browser.js("document.body.innerHTML").should.include(%{hello <div id="foo">world</div>})
  end
  
  it "performance" do
    n = 100
    time = 
      Benchmark.realtime {
        n.times do
          @browser.load_html(
            (<<-HTML)
            <html>
              <body>
              	hello <div id="the_spot"></div>
        	
              	<script type="text/javascript">
                	document.getElementById('the_spot').innerHTML='world'
              	</script>
              </body>
            </html>
            HTML
          )
        end
      }
    puts "basic html load: #{n} requests in #{time}s  #{(time*1000)/n}ms/r  #{n.to_f/time.to_f}r/s"
  end
end