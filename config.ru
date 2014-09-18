#Put rack stuff into this file for later use.  
#Type this in the bash.   
$LOAD_PATH.push '.'
#export RUBYLIB = '.'

require 'rack'
require 'main'

app = Network::App.new
app = Rack::ShowExceptions.new(app)
app = Rack::Reloader.new(app) 
app = Rack::ShowStatus.new(app) 
app = Rack::Session::Cookie.new(app) 
app = Rack::Static.new(app, {
	:urls => ["/public"]
	})

Rack::Handler::WEBrick.run app


