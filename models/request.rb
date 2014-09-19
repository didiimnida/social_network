module Network      
        class Request
            attr_reader :id
            attr_accessor  :requester_id, :accepter_id, :accepter
            def initialize(data)
                @requester_id = data['requester_id']
                @accepter_id = data['accepter_id']
                @id = data['id']
                @accepter = data['accepter']
            end 
        end
end