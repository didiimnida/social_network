module Network
    class Comment #Comments privacy will be set by status owner.  
    	attr_reader :id
    	attr_accessor :commenter_id, :status_id, :comment, :date, :reply_to, :comment_from
    	def initialize(data)
    		@id = data['id']
    		@commenter_id = data['commenter_id']
    		@status_id = data['status_id']
    		@comment = data['comment']
    		@date = data['date']
    		@reply_to = data['reply_to'] #This will include user object + status object.
    		@comment_from = data['comment_from'] #This will include a user object.  
    	end  
    end
end