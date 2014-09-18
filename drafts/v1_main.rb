require 'rack'
require 'erubis'
require 'sqlite3'
require 'ap'
require 'pry'

module Network #Encasing everything in an overall module.  

	#These classes what the App class will need.  
	class User 
		attr_reader :id
		attr_accessor :username, :email, :password

		#Want to get this from user when they are registering! Connect to webpage.
		def initialize(data) 
			@id = data['id']
			@username = data['username']
		end

	end #end User

	#This class will handle everything related to the database/ORM.
	class ORM 
		TABLE_CLASS_MAP = {
			:users => User
		}

		DB_FILE = 'socialnetwork.db'

		def initialize #Step by step database creation. 
			delete_database_if_it_exists
			connect_to_database
			configure_database
			load_schema
			load_data
		end

		#Database creation:
		def delete_database_if_it_exists
			if File.exist? DB_FILE
				File.delete DB_FILE
			end
		end

		def connect_to_database
			@db = SQLite3::Database.new(DB_FILE)
		end

		def configure_database
			@db.execute 'PRAGMA foreign_keys = true;'
			@db.results_as_hash = true
		end

		def load_schema
			@db.execute_batch File.read('sql/schema.sql')
		end

		#This is just practice data.  Will actually need to get the data from users.
		def load_data
			@db.execute_batch File.read('sql/data.sql')
		end

	end #end ORM

	#This class will handle everything related to web/display/functionality of the app.
	class App 	
		def initialize()
			orm = ORM.new
		end

		def call(env)
			ap env  
			request = Rack::Request.new(env)
			response = handle_request(request)
			return response.finish()
		end

		# def render(name, locals={})
		# 	file = File.read("views/"+name+".erb")
		# 	Erubis::Eruby.new(file).result(locals)
		# end

		def handle_request(request)
			Rack::Request.new do |r|

				case request.path_info

				# when '/index', '/'

				# #r.write render("index", {}) #Want to send in stuff from database here...
				# r.write render("index")

				when '/test'
					r.write = "I am testing this."
					r.status = 404

				else
					r.status = 404
				end #end switch

			end #end block passed to Rack::Response.new

		end #end handle_request

	end #end App

end #end module


Rack::Handler::WEBrick.run Network::App.new
#Run config.ru instead to make use of middleware.  



