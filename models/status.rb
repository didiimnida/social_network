module Network
	class Status
        attr_reader :id
        attr_accessor :author_id, :status, :date, :author 
        def initialize(data)
        	@id = data['id']
            @author_id = data['author_id']
            @status = data['status']
            @date = data['date']
            @author = data['author'] 
        end
	end
end