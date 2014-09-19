module Network
	class App
		def welcome_sms(send_to, username)
			account_sid = 'AC73a66c72f8615ee061975645ea0efafd'
			auth_token = '3e176b8725750222d8d8b48e7a850c29'
			@client = Twilio::REST::Client.new account_sid, auth_token
	 
			message = @client.account.messages.create(:body => "Welcome to the social network, #{username}!",
			    :to => "#{send_to}",    
			    :from => "+18169120447")   
		end	

		def send_sms(send_to, from, message)
			account_sid = 'AC73a66c72f8615ee061975645ea0efafd'
			auth_token = '3e176b8725750222d8d8b48e7a850c29'
			@client = Twilio::REST::Client.new account_sid, auth_token
			message = @client.account.messages.create(:body => "#{message} From: #{from} via social network!",
			    :to => "#{send_to}",     
			    :from => "+18169120447") #Site admin Twilio number.  
		end
		
		#ADMIN ONLY! 
		def notification_sms(users, message)
			account_sid = 'AC73a66c72f8615ee061975645ea0efafd'
			auth_token = '3e176b8725750222d8d8b48e7a850c29'
			@client = Twilio::REST::Client.new account_sid, auth_token

			users.each do |key, value|		    
		    @client.account.messages.create(:from => "+18169120447",
		    :to => key,
		    :body => "Hello #{value}, #{message}")
	  		puts "Sent message to #{value}"
	  		end
		end
	end
end



#Notes:
#Can send in number with or without +1
# send_to = "+19259229516"
# send_to = "8165171305"
# username = "Diana without+1"
# welcome_sms(send_to, username)







