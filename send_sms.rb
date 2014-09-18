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
			message = @client.account.messages.create(:body => "#{message} From:#{from} using the social network!",
			    :to => "#{send_to}",     
			    :from => "+18169120447") #Site admin Twilio number.  
		end
		
		#users = {"+18165171305" => "Diana Hilton"} #Send in hash. 
		def notification_sms(users, messsage)
			sid = "PN1af728eb3050c90a1a8c19b990622895"
			account_sid = 'AC73a66c72f8615ee061975645ea0efafd'
			auth_token = '3e176b8725750222d8d8b48e7a850c29'
			client = Twilio::REST::Client.new account_sid, auth_token

			from = "+18169120447" # Your Twilio number

			users.each do |key, value|
		    client.account.messages.create(
		    :from => from,
		    :to => key,
		    :body => "We've made updates to the social network, #{value}!  
		    Come back and visit us to enjoy the changes."
	  		)
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







