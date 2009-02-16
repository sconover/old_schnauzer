require "rubygems"
require "sinatra"

set :public, File.dirname(__FILE__) + '/public'

get '/foo/hi' do
  "hi I'm a web app"
end

get '/echo/:to_echo' do
  "#{params[:to_echo]}, echoed back"
end


get '/ajax' do

  %{
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
  }
end