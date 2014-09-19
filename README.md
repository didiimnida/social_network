social_network
=============

Implementing a basic social network app using Ruby (no Rails), SQL, Rack and ORM (no Active Record).  Uses basic Mailgun and Twilio API. 

This social network application will be able to login, register and authenticate users.

Users can update a status, add/accept friends, comment on friends statuses.  

Run.  From the command line, run "config".  The server will be up and running.  

Site admin_id is default set to user_id = 1.  To change, must alter in "main.rb" file. (Use "command-f" to search "ASSIGN ADMIN!!!" in "main.rb".) 

WARNING:  If you want to save the database after turning off the server, please comment out the following methods before restarting: 
1. delete_database_if_it_exists()
2. load_schema()
3. load_data()
Use "command-f" to search "COMMENT OUT TO KEEP DATABASE" in "main.rb" file.
Note:  Will fix this in future versions once I am done testing the code and adding database features.    

Visit [Trello](https://trello.com/b/HpjBCWks/social-network) to see the planning behind the development process.   
