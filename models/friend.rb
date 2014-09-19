module Network
	    class Friend
	    	attr_accessor  :request_id, :accept_id, :my_friend
	    	def initialize(data)
	    		@request_id = data['request_id']
	    		@accept_id = data['accept_id']
	            @my_friend = data['my_friend']
	    	end 
	    end
end
