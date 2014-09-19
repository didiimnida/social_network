module Network
	class User 
			attr_reader :id
			attr_accessor :email, :password, :username, :interests, :mobile, :picture
			def initialize(data) 
				@id = data['id']
				@email = data['email']
				@password = data['password']
				@username = data['username']
				@interests = data['interests'] 
				@mobile = data['mobile']
				@picture = data['picture']
			end

			def password_is_correct? password
				return password == @password
			end
	end
end