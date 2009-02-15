require "rubygems"
require "lib/safari"
require "spec"

describe Safari do
  before do
    @browser = Safari.new
  end
  
  it "loads and displays html" do
    @browser.load_html(%{
      <html>
        <body>
        	<i>hello world</i>
        </body>
      </html>
    })

    @browser.document.innerHTML.should include("<i>hello world</i>")
  end
  
  it "uses base url provided to make absolute urls" do
    @browser.load_html(%{
      <html>
        <body>
        	<a id="mylink" href="/mypage.html">linky</a>
        </body>
      </html>
    }, "http://bar")
    
    @browser.document.getElementsByTagName("A") \
      .item(0).href.should == "http://bar/mypage.html"
  end
  
  it "executes javascript" do
    @browser.load_html(%{
      <html>
        <body>
        	hello <div id="the_spot"></div>
        	
        	<script type="text/javascript">
          	document.getElementById('the_spot').innerHTML='world'
        	</script>
        </body>
      </html>
    })
    @browser.document.innerHTML.should include(%{hello <div id="the_spot">world</div>})
  end
  
  it "load from url" do
    @browser.load_url("file://#{File.expand_path("spec/little_page.html")}")
    @browser.document.innerHTML.should include(%{hello <div id="foo">world</div>})
  end
end