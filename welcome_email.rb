module Network
	DOMAIN = 'sandboxb853f2dd106c43f5aad5c9e771c33e10.mailgun.org'
	API_KEY = 'key-b8c1f56234558280a75ac5a1c69b9b69'
	class App
		def send_welcome(email, user)
		username = 'api'
		password = API_KEY
		url = "https://api.mailgun.net/v2/#{DOMAIN}/messages"

		params = {
		    :from => "Social Network <postmaster@#{DOMAIN}>",
		    :to => "#{email}",
		    :subject => "WELCOME #{user}!",
		    :text => "
		    	Welcome to the social network app!
		    	Confirm your email address through this link to complete the registration process:
		    	http://localhost:8080/login
		    "
		}

		options = {
		    method: :post,
		    params: params,
		    userpwd: "#{username}:#{password}"
		}

		request = Typhoeus::Request.new(url, options)

		response = request.run()

		#p response  #This is printing a ton of stuff.  NOT an error! 
		end 
	end
end