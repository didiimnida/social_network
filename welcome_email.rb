# require 'pry'
# require 'typhoeus'

module Network
	DOMAIN = 'sandboxb853f2dd106c43f5aad5c9e771c33e10.mailgun.org'
	API_KEY = 'key-b8c1f56234558280a75ac5a1c69b9b69'
	class App

		#Don't tab or email formatting will be off. 
		def welcome_message()
return "Welcome to the social network app!
Confirm your email address through this link to complete the registration process:
http://localhost:8080/login"
		end

		def send_email(email, user, message)
		username = 'api'
		password = API_KEY
		url = "https://api.mailgun.net/v2/#{DOMAIN}/messages"

		params = {
		    :from => "Social Network <postmaster@#{DOMAIN}>",
		    :to => "#{email}",
		    :subject => "WELCOME #{user}!",
		    :text => "#{message}"
		}

		options = {
		    method: :post,
		    params: params,
		    userpwd: "#{username}:#{password}"
		}

		request = Typhoeus::Request.new(url, options)

		response = request.run()
 
		end 

		def email_all_users(users, message)
		username = 'api'
		password = API_KEY
		url = "https://api.mailgun.net/v2/#{DOMAIN}/messages"
		users.each do |email, user|

			params = {
			    :from => "Social Network <postmaster@#{DOMAIN}>",
			    :to => "#{email}",
			    :subject => "WELCOME #{user}!",
			    :text => "#{message}"
			}
			options = {
			    method: :post,
			    params: params,
			    userpwd: "#{username}:#{password}"
			}

			request = Typhoeus::Request.new(url, options)

			response = request.run()
		end	

		end

	end
end

