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
require_relative 'models/request'
require_relative 'models/friend'

module Network   
	
	class ORM 
		TABLE_CLASS_MAP = {
			:users => User,
			:statuses => Status,
			:friends => Friend,
			:comments => Comment,
            :requests => Request
		}

		DB_FILE = 'socialnetwork.db'

		def initialize  
			delete_database_if_it_exists() #COMMENT OUT TO KEEP DATABASE. 
			connect_to_database()
			configure_database()
			load_schema() #COMMENT OUT TO KEEP DATABASE. 
			load_data() #COMMENT OUT TO KEEP DATABASE. 
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
				SET interests = '#{me.interests}',
                 picture = '#{me.picture}',
                mobile = '#{me.mobile}',
                username = '#{me.username}'
				WHERE id = '#{me.id}';
			SQL
		end

        #OK
        def add_request(requester_id, accepter_id) 
            @db.execute <<-SQL
                INSERT INTO 
                    requests (requester_id, accepter_id) 
                VALUES
                    ('#{requester_id}', '#{accepter_id}');
            SQL
        end

        #Put it in both ways here OR just do two loops later?:
        def add_friend(request_id, accept_id) 
            @db.execute <<-SQL
                INSERT INTO 
                    friends (request_id, accept_id) 
                VALUES
                    ('#{request_id}', '#{accept_id}');
            SQL
            
            @db.execute <<-SQL
                INSERT INTO 
                    friends (request_id, accept_id) 
                VALUES
                    ('#{accept_id}','#{request_id}');
            SQL
        end

        def delete_request(request_id)
            @db.execute <<-SQL
                DELETE FROM requests 
                WHERE id = '#{request_id}';
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

	end 

    class App

        def initialize()
            @orm = ORM.new 
            @admin_id = 1 #ASSIGN ADMIN!!!
        end

        #RENDERING:
        def render(name, locals={})
        	file = File.read("views/"+name+".erb") 
        	Erubis::Eruby.new(file).result(locals)
        end

        #DATABASE HELPERS:
        def get_users()
            users = @orm.all(:users)
        end

        def get_statuses()  
            all_statuses = @orm.relational(:statuses, get_users()) #Append user objects.
            statuses = @orm.relational_all(:statuses, all_statuses) #Wrap into a list of status + user objects.
        end

        def get_comments()
            all_comments = @orm.relational_comments(:comments, get_statuses(), get_users()) #Append 'status + author' object list & 'user' object list to comments.             
            comments = @orm.relational_all(:comments, all_comments) #Wrap into a list of comments + commenter + status + author objects.
        end

        #SELECTORS:
        def select(id) 
            get_users.find {|user| user.id == id}    
        end

        def select_status(id)
			get_statuses.find{|status| status.id == id}
		end

        #User login/signup.
        def find_user_by_email email
            get_users.find do |user|
                p user
                user.email == email
            end
        end

        def same_password?(password1, password2)
            if (password1 == '' || password1 != password2)  
                return false 
            else 
                return true 
            end
        end

        def find_friends(me)
            @friends_simple = @orm.all(:friends)
                    @requests_simple = @orm.all(:requests)
                    user_friends = [] 
                    @friends_simple.each do |connection|
                            if connection.request_id == me.id
                                @users.each do |user|
                                    if connection.accept_id == user.id
                                        user_friends.push(user)
                                    end
                                end
                            end
                        end
        end

        #RACK
        def call(env)
       		ap env
            request = Rack::Request.new(env)
            response = handle_request(request) 
            return response.finish()
        end

        def handle_request(request)

            Rack::Response.new do |r|

                case request.path_info

                #User login/logout/register: 
                when '/login', '/'
                	notification = "Find Friends."
                    r.write render("login", {notification: notification})

                when '/logout' 
                    r.delete_cookie 'rack.session' #Just deleting the cookie!
                	r.redirect '/login'

                when '/users/login' #post!
                	if request.post?
                        user = find_user_by_email(request.POST['email'])

                        if user.nil? == false
                            if user.password_is_correct?(request.POST['password']) 
                                request.session['user_id'] = user.id 
                                r.redirect '/index' 
                            else
                                notification = "Password is incorrect."
                                r.write render("login", {notification: notification})
                            end
                        else
                            notification = "No such user with that email."
                            r.write render("login", {notification: notification})     
                        end
                    end

                when '/users/register' 
                	if request.post? 
                        user = find_user_by_email(request.POST['email'])                           
                		if (same_password?(request.POST['password2'], request.POST['password']) && user.nil?)
                            #Do some regex here.  Make sure nothing is nil or in wrong format.  
                			@orm.add_user(request.POST['email'], request.POST['password'], request.POST['username'], request.POST['mobile']) 
                			notification = "You are now registered.  Please log into user area!"
                 			r.write render("login", {notification: notification})
                 			send_email(request.POST['email'], request.POST['username'], welcome_message()) #MAILGUN!
                 			welcome_sms(request.POST['mobile'], request.POST['username']) #TWILIO!
                 		elsif user.nil? == false
                 			notification = "Email already registered. Try again!"
                 			r.write render("login", {notification: notification})
                		elsif same_password?(request.POST['password2'], request.POST['password']) == false
                			notification = "Sorry! Passwords do not match. Try again!"
                 			r.write render("login", {notification: notification})
                 		else
                 			r.redirect '/login'
                		end
                	end

                #User Session pages: Should be logged in with cookies! PUT LOGIC SWITCH HERE?
                when '/index'   
                	if request.session['user_id']
                    my_id = request.session['user_id'].to_i
                    me = select(my_id)
                    @users = get_users()  
                    @statuses = get_statuses()  
                    @comments = get_comments()
                    
                    #START Friends Filter
                    @friends_simple = @orm.all(:friends)
                    @requests_simple = @orm.all(:requests)
                    user_friends = [] 
                    @friends_simple.each do |connection|
                            if connection.request_id == me.id
                                @users.each do |user|
                                    if connection.accept_id == user.id
                                        user_friends.push(user)
                                    end
                                end
                            end
                        end
                    #End Friends Filter             

                	r.write render("index", {users: user_friends, statuses: @statuses, comments: @comments, me: me})
                	else 
                		notification = "Please log in to see this page."
                 		r.write render("login", {notification: notification})
                	end  

                when '/home' #Newsfeed
                	if request.session['user_id']
                       my_id = request.session['user_id'].to_i
                       me = select(my_id)
                       
                       # #Start Filter Statuses
                       #  user_friends_statuses = [] 
                       #  @friends_simple.each do |connection|
                       #          if connection.request_id == me.id
                       #              @statuses.each do |status|
                       #                  if connection.accept_id == status.author.id
                       #                      user_friends_statuses.push(status)
                       #                  end
                       #              end
                       #          end
                       #      end
                       #  binding.pry
                       #  #End Filter Statuses
                       #Need to filter statuses & comments!!!

                	   r.write render("home", {users: @users, statuses: @statuses, comments: @comments, me: me})
                	else 
                		notification = "Please log in to see this page."
                 		r.write render("login", {notification: notification})
                	end

                when '/friends/' #Should be logged in! #Look at a friend's page. 
                    if request.session['user_id']
                    my_id = request.session['user_id'].to_i
                	id = request.GET['friend'].to_i
                    #FILTER
                	r.write render("friend", {friend: select(id), me: select(my_id), users: @users, statuses: @statuses, comments: @comments})
                    else
                        notification = "Please log in to see this page."
                        r.write render("login", {notification: notification})
                    end

                #Start status CRUD. 
                when '/status/create' 
                    my_id = request.session['user_id'].to_i #Can I carry my_id through a redirect?  Behave differently?
                	date = Time.now.to_s.split(' ')[0]+" " + Time.now.to_s.split(' ')[1]             
                	@orm.add_status(my_id, request.POST['status'], date)
                	r.redirect '/index'

                when '/status/show/' 
                    my_id = request.session['user_id'].to_i
                	id = request.GET['id'].to_i
                	r.write render("show", {id: id, status: select_status(id), me: select(my_id)})

                when '/status/edit/' 
                    my_id = request.session['user_id'].to_i
                	id = request.GET['id'].to_i #Not sure why this works with the post request.  Why is query string working?
                    status = select_status(id)
                    if status.author_id == my_id
                    status.status = request.POST['status']
                	@orm.update_status(status)                 	  
                	r.redirect '/index'
                    else #Another user can still view the edit page, but can not make changes. 
                    notification = "You are not authorized to change this page."
                    r.write render("login", {notification: notification})
                    end 

                when '/status/delete'
                    id = request.params['id'].to_i
                    status = select_status(id) 
                    my_id = request.session['user_id'].to_i
                    if status.author_id == my_id
                	@orm.delete_status(status)
                	r.redirect '/index' 
                    else #Another user can still view the edit page, but can not make changes. 
                    notification = "You are not authorized to change this page."
                    r.write render("login", {notification: notification})
                    end 
                #End status CRUD. 

                #Start User Settings CRUD. Change URI names? 
                when '/about' #Edit all the user settings on this page.
                    if request.session['user_id']
                    my_id = request.session['user_id'].to_i
                    r.write render("about", {me: select(my_id)})
                    else 
                        notification = "Please log in to see this page."
                        r.write render("login", {notification: notification})
                    end
                
                when '/about/edit'  
                    my_id = request.session['user_id'].to_i 
                    me = select(my_id) 
                    me.interests = request.POST['interests']
                    me.picture = request.POST['picture']
                    me.mobile = request.POST['mobile']
                    me.username = request.POST['username']
                    @orm.update_me(me)                  
                    r.redirect '/index'
                #End user settings CRUD.  

                #TWILIO API!  
            	when '/text/create' 
                    my_id = request.session['user_id'].to_i
                    me = select(my_id) 
            		send_to = request.params['send_to']
            		message = request.params['message']
            		from = me.username
                    send_sms(send_to, from, message)
                    notification = "#{from} successfully sent a text message '#{message}'"
                    r.write render("popup", {notification: notification, me: me})

                #Start comments CRUD           		
            	when '/comments/create' 
                    my_id = request.session['user_id'].to_i
            		if request.POST['comment'] == ''
            		   view = request.params['view'].to_s	
            		else   
	            		date = Time.now.to_s.split(' ')[0]+" " + Time.now.to_s.split(' ')[1]   
	            		status_id = request.params['id_to_comment'].to_i
                        friend_id = request.params['author_id'].to_i #Need this to render friend page. 
	            		view = request.params['view'].to_s
	            		@orm.add_comment(my_id, status_id, request.POST['comment'], date)         
	                	@comments = get_comments()
					end
						r.write render("#{view}", {me: select(my_id), friend: select(friend_id), users: @users, statuses: @statuses, comments: @comments})

                when '/comments/delete' 
                #NEED TO DO. User should be able to delete ALL comments and commenter should be able to delete their comment. 
                    my_id = request.session['user_id'].to_i
                    id = request.params['id'].to_i
                    #Need to know commenter, comment_id...
                    comment = select_comment(id) #Need to write this method.  
                    @orm.delete_comment(comment) #Need to write this method. 
                    r.redirect '/index' 
               	#End comments CRUD

               when '/finder'
                    if request.session['user_id']
                       my_id = request.session['user_id'].to_i
                       me = select(my_id)

                        #START No-Friends Filter
                        #Need to make a positive user list first, 
                        #then take that list and compare everything on that list to one user at a time.
                        #End Friends Filter 
                        #FILTER

                       path = '/addfriend'
                       r.write render("finder", {users: @users, me: me, path: path})
                    else 
                        notification = "Please log in to see this page."
                        r.write render("login", {notification: notification})
                    end

                when '/addfriend'
                    my_id = request.session['user_id'].to_i            
                    @orm.add_request(my_id, request.POST['friend_id'])
                    r.redirect '/index'

                when '/accept'
                    if request.session['user_id']
                       my_id = request.session['user_id'].to_i
                       path = '/acceptfriend'
                       #FILTER
                       r.write render("finder", {users: @users, me: select(my_id), path: path}) 
                       #Might need to make a different ERB page???  
                    else 
                        notification = "Please log in to see this page."
                        r.write render("login", {notification: notification})
                    end

                when '/acceptfriend'
                    my_id = request.session['user_id'].to_i         
                    @orm.add_friend(my_id, request.POST['friend_id'])
                    #Need to implement the filters?  
                    #@orm.delete_request(request_id)
                    r.redirect '/index'

               #ADMIN PAGES
               when '/admin'
                    if request.session['user_id'] == @admin_id   
                       r.write render("admin", {me: select(@admin_id)})
                    else 
                        notification = "You are not authorized to view this page. Login to your account again."
                        r.write render("login", {notification: notification})
                    end

                when '/admin/smsnotify'
                    if request.session['user_id'] == @admin_id   
                        message = request.params['smsnotify']
                        send_to ={}
                        @users.each do |user|
                            key = user.mobile
                            value = user.username
                            send_to[key] = value
                        end
                        notification_sms(send_to, message)
                        notification = "Social network sent the follwing text message to all users: #{message}"
                        r.write render("popup", {notification: notification, me: select(@admin_id)})
                    else 
                        notification = "You are not authorized to view this page. Login to your account again."
                        r.write render("login", {notification: notification})
                    end

                when '/admin/emailnotify'
                    if request.session['user_id'] == @admin_id
                        message = request.params['emailnotify']
                        send_to ={}
                        @users.each do |user|
                            key = user.email
                            value = user.username
                            send_to[key] = value
                        end
                        email_all_users(send_to, message)
                        notification = "Social network the following email to all users: #{message}"
                        r.write render("popup", {notification: notification, me: select(@admin_id)})
                    else
                        notification = "You are not authorized to view this page. Login to your account again."
                        r.write render("login", {notification: notification})
                    end

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



