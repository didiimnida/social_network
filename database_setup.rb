#Want to take this out of main and run it from this file.  
module Network
	class ORM
		def delete_database_if_it_exists
			if File.exist? DB_FILE
			File.delete DB_FILE
			end
		end

		def connect_to_database
			@db = SQLite3::Database.new(DB_FILE)
		end

		def configure_database
			@db.execute 'PRAGMA foreign_keys = true;'
			@db.results_as_hash = true
		end

		def load_schema
			@db.execute_batch File.read('sql/schema.sql')
		end

		#This is just practice data.  Will actually need to get the data from users.
		def load_data
			@db.execute_batch File.read('sql/data.sql')
		end
	end
end