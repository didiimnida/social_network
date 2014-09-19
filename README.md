social_network
=============

Implementing a basic social network app using Ruby (no Rails), SQL, Rack and ORM (no Active Record).  Uses basic Mailgun and Twilio API. 

This social network application will be able to login, register and authenticate users.

Users can update a status, add/accept friends, comment on friends statuses.  

Run.  From the command line, run "config".  The server will be up and running.  

WARNING:  If you want to save the database after turning off the server, please comment out the following methods before restarting: 
1. delete_database_if_it_exists()
2. load_schema()
3. load_data()
You will find the method calls in "main.rb" if you use (command-f) to search.
Note:  Will fix this in future versions once I am done testing the code and adding database features.    

Visit [Trello](https://trello.com/b/HpjBCWks/social-network) to see the planning behind the development process.   
