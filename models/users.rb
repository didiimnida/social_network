module Network
	class User 
			attr_reader :id
			attr_accessor :email, :password, :username, :interests, :mobile
			def initialize(data) 
				@id = data['id']
				@email = data['email']
				@password = data['password']
				@username = data['username']
				@interests = data['interests'] 
				@mobile = data['mobile']
			end
	end
end