require 'rack'
require 'erubis'
require 'sqlite3'
require 'ap'
require 'pry'
require 'typhoeus'
require 'rest_client'
require 'rubygems'
require 'twilio-ruby'
require_relative 'database_setup'
require_relative 'welcome_email'
require_relative 'send_sms'
require_relative 'models/users'
require_relative 'models/status'
require_relative 'models/comment'
require_relative 'models/friend'

module Network   
	#Haven't done anything with this yet, so will move it later to models folder. 
    class Friend
    	attr_accessor :request_id, :accept_id
    	def initialize(data)
    		@request_id = data['request_id']
    		@accept_id = data['accept_id']
    	end 
    end

	#This class will handle everything related to the database/ORM.
	class ORM 
		TABLE_CLASS_MAP = {
			:users => User,
			:statuses => Status,
			:friends => Friend,
			:comments => Comment
		}

		DB_FILE = 'socialnetwork.db'

		def initialize  
			delete_database_if_it_exists()
			connect_to_database()
			configure_database()
			load_schema()
			load_data()
		end

		def all(table)  
			results = @db.execute("select * from #{table}")
			results.map do |row| 
            model = TABLE_CLASS_MAP[table]
            model.new(row)
       	 	end
		end

		#Appending the user objects to the status database list.
		def relational(table, object_list) 
			results = @db.execute("select * from #{table}")
			users = object_list  
			results.map do |row|
				users.each do |user|
				if row['author_id'] == user.id
				   row['author'] = user
				end
				end
			end
			return results
		end

		#Make the new list an object list!
		def relational_all(table, relational_results)
			relational_results.map do |row|
				model = TABLE_CLASS_MAP[table]
				model.new(row)
			end
		end

		#Appending the status+user objects and commenter(user) objects to the comments database list.
		def relational_comments(table, object_list, object_list_2) 
			results = @db.execute("select * from #{table}") 
			statuses = object_list 
			users =  object_list_2
			results.map do |row|
				statuses.each do |status|
					if row['status_id'] == status.id 
					   row['reply_to'] = status 
					end
				end
				users.each do |user|
					if row['commenter_id'] == user.id 
					   row['comment_from'] = user	
					end
				end
			end
			return results
		end

		def add_user(email, password, username, mobile) 
        @db.execute <<-SQL
            INSERT INTO 
            	users (email, password, username, interests, mobile) 
            VALUES
                ('#{email}', '#{password}', '#{username}', 'Who is #{username}?', '#{mobile}');
        SQL
		end

		def update_me(me)
			@db.execute <<-SQL
				UPDATE users 
				SET interests = '#{me.interests}' 
				WHERE id = '#{me.id}';
			SQL
		end

		def add_status(author_id, status, date) 
        @db.execute <<-SQL
            INSERT INTO 
            	statuses (author_id, status, date) 
            VALUES
                ('#{author_id}', '#{status}', '#{date}');
        SQL
		end

		def update_status(status)
			@db.execute <<-SQL
				UPDATE statuses 
				SET status = '#{status.status}' 
				WHERE id = '#{status.id}';
			SQL
		end

		def delete_status(status)
			@db.execute <<-SQL
				DELETE FROM statuses  
				WHERE id = '#{status.id}';
			SQL
		end

		def add_comment(commenter_id, status_id, comment, date)
			@db.execute <<-SQL
            INSERT INTO 
            	comments (commenter_id, status_id, comment, date) 
            VALUES
                ('#{commenter_id}', '#{status_id}', '#{comment}', '#{date}');
        SQL
		end

		#User login/signup.
		def check_password(email, password)
			password_check = @db.execute <<-SQL
			select password, id from users where email='#{email}';
			SQL
			if (password == '' || password_check[0]['password'] != password)
				return false
			else
				return password_check[0]['id']
			end
		end

		def same_password?(password1, password2)
			if (password1 == '' || password1 != password2)	
				return false 
			else 
				return true 
			end
		end

		def unique_user?(email)
			check = @db.execute <<-SQL
			select email from users;
			SQL
			i = 0 
			for i in 0..(check.length-1) 
				if email == check[i]['email']
					return email
				end
			end
			"Checked"
		end

	end 

    class App

        def initialize()
            @orm = ORM.new 
            @my_id = 'temp'   
        end

        def render(name, locals={})
        	file = File.read("views/"+name+".erb") 
        	Erubis::Eruby.new(file).result(locals)
        end

        def select(id)
            @users.find{|user| user.id == id}
        end

        def select_status(id)
			@statuses.find{|status| status.id == id}
		end

        def call(env)
       		ap env
            request = Rack::Request.new(env)
            response = handle_request(request) 
            return response.finish()
        end

        def handle_request(request)

            Rack::Response.new do |r|

			#Want browser to remember this information. 
			#response.set_cookie('user_id', '1')

			#Use the cookie to look up user object. (Users is an array of user objects and the request.cookies is the user id based on the cookie.)
			#user = ORM.find "users", request.cookies['user_id'].to_i

			#request.session['user_id'] = user_id
			#Using the rack.session to save.

			#The user_id is now encrypted by Rack.  Rack has the deencryption.

                case request.path_info

                #User login/logout/register: 
                when '/login', '/' 
                	notification = "Find Friends."
                    r.write render("login", {notification: notification})

                when '/logout' 
                	@my_id = 'temp'
                	r.redirect '/login'

                when '/users/login' #post!
                	if request.post?
                		if @orm.unique_user?(request.POST['email']) == request.POST['email']
	                		if @my_id = @orm.check_password(request.POST['email'], request.POST['password'])
	                		   request.session['user_id'] = @my_id #Save this in the session area.  
	                		   r.redirect '/index' #Once we log in you MUST go through the index page. 
	                		else
	                		   notification = "Password is incorrect."
                 		 	   r.write render("login", {notification: notification})
	                		end
	                	else
	                		notification = "Email is not registered."
                 			r.write render("login", {notification: notification})
                 		end	       
                	end

                when '/users/register' #post! 
                	if request.post? 
                		if (@orm.same_password?(request.POST['password2'], request.POST['password']) && @orm.unique_user?(request.POST['email']) == "Checked")
                			@orm.add_user(request.POST['email'], request.POST['password'], request.POST['username'], request.POST['mobile']) 
                			notification = "You are now registered.  Please log into user area!"
                 			r.write render("login", {notification: notification})
                 			send_welcome(request.POST['email'], request.POST['username']) 
                 			welcome_sms(request.POST['mobile'], request.POST['username'])
                 		elsif @orm.unique_user?(request.POST['email']) == false
                 			notification = "Email already registered. Try again!"
                 			r.write render("login", {notification: notification})
                		elsif @orm.same_password?(request.POST['password2'], request.POST['password']) == false
                			notification = "Sorry! Passwords do not match. Try again!"
                 			r.write render("login", {notification: notification})
                 		else
                 			r.redirect '/login'
                		end
                	end

                #User Session pages:
                when '/index'  #Call all the data here b/c this page displays everything AND every logged in user must go through this page first.
                	if @my_id !='temp'
                	#Generate object list of users. 
                	@users = @orm.all(:users)
                	#Append the user objects to the status data.
                	@all_statuses = @orm.relational(:statuses, @users)
                	#Generate object list of statuses. (ORDERED!  If you get statuses out of the comment structure, won't retain order.)
                	@statuses = @orm.relational_all(:statuses, @all_statuses)
                	#Append the comments to the @statuses.  
                	@all_comments = @orm.relational_comments(:comments, @statuses, @users)             
                	@comments = @orm.relational_all(:comments, @all_comments) 

                	#@friends = @orm.all(:friends) #Not using yet.

                	@me = select(@my_id)
                	r.write render("index", {users: @users, statuses: @statuses, comments: @comments, me: @me})
                	else 
                		notification = "Please log in to see this page."
                 		r.write render("login", {notification: notification})
                	end  
  
                when '/about' #User can input information about themselves.
                	if @my_id !='temp'
                	r.write render("about", {users: @users, me: @me})
                	else 
                		notification = "Please log in to see this page."
                 		r.write render("login", {notification: notification})
                	end

                when '/about/edit' #post! #Edit the "about" section.  
                	@me.interests = request.POST['interests']
                	@orm.update_me(@me)                 	
                	r.redirect '/index'

                when '/home' #Newsfeed of all users friends.
                	if @my_id !='temp'
                	r.write render("home", {users: @users, statuses: @statuses, comments: @comments, me: @me})
                	else 
                		notification = "Please log in to see this page."
                 		r.write render("login", {notification: notification})
                	end

                when '/friends/' #Choose a particular friend to look at.  
                	id = request.GET['friend'].to_i
                	@friend = select(id)
                	r.write render("friend", {friend: @friend, me: @me, users: @users, statuses: @statuses, comments: @comments})

                #Start status CRUD. 
                when '/status/create'
                	date = Time.now.to_s.split(' ')[0]+" " + Time.now.to_s.split(' ')[1]             
                	@orm.add_status(@my_id, request.POST['status'], date)
                	r.redirect '/index'

                when '/status/show/'  
                	id = request.GET['id'].to_i  
                	@status = select_status(id) #Status already set here, so don't need to find it again in delete method.
                	r.write render("show", {id: id, status: @status, me: @me})

                when '/status/edit/' 
                	id = request.GET['id'].to_i #Don't need this either since got status when loading the show page.
                	@status.status = request.POST['status']
                	@orm.update_status(@status)                 	  
                	r.redirect '/index'

                when '/status/delete'  
                	@orm.delete_status(@status)
                	r.redirect '/index' 
                #End status CRUD. 

            	when '/text/create'
            		send_to = request.params['send_to']
            		message = request.params['message']
            		from = @me.username
            		send_sms(send_to, from, message)
            		r.write "#{from} wants to text the message '#{message}' to #{send_to}!"

                #Start comments CRUD           		
            	when '/comments/create' #post
            		if request.POST['comment'] == ''
            		   view = request.params['view'].to_s	
            		else   
	            		date = Time.now.to_s.split(' ')[0]+" " + Time.now.to_s.split(' ')[1]   
	            		status_id = request.params['id_to_comment'].to_i
	            		view = request.params['view'].to_s
	            		@orm.add_comment(@my_id, status_id, request.POST['comment'], date)
	            		@all_comments = @orm.relational_comments(:comments, @statuses, @users)             
	                	@comments = @orm.relational_all(:comments, @all_comments)
					end
						r.write render("#{view}", {me: @me, users: @users, friend: @friend, statuses: @statuses, comments: @comments})
               	#End comments CRUD

                else 
                    r.write "Sorry! This is an invalid url!"
                    r.status = 404

                end #end case statement

            end #end block passed to Rack::Response.new 

        end #handle_request local method

    end #end App class

end #end module


#Rack::Handler::WEBrick.run Network::App.new
#Run config.ru instead to make use of middleware.  



