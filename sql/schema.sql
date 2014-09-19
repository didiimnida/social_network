CREATE TABLE users (
    id          INTEGER PRIMARY KEY,
    email       TEXT,
    password	TEXT,
    username 	TEXT,
    interests 	TEXT,
    mobile		VARCHAR(255), 
    picture     TEXT
);

-- Add time stamp!
CREATE TABLE statuses (
    id          INTEGER PRIMARY KEY,
    author_id   INTEGER NOT NULL,
    status      TEXT,
    date		TEXT,
    FOREIGN KEY(author_id) REFERENCES users(id)
);

CREATE TABLE comments (
	id          INTEGER PRIMARY KEY,
    commenter_id   INTEGER NOT NULL,
    status_id 	INTEGER NOT NULL,
    comment     TEXT,
    date 		TEXT	
);

CREATE TABLE friends (
	request_id INTEGER NOT NULL,
	accept_id  INTEGER NOT NULL,
    FOREIGN KEY(request_id) REFERENCES users(id),
    FOREIGN KEY(accept_id)  REFERENCES users(id)
);  

--This file should only be loaded once.  It defines the instance variables
--that will be taken in the class (name with CamelCase and not plural.)
--This is the standard schema setup.  
--Don't constraint comments with foreign keys or the delete will fail. 
-- FOREIGN KEY(commenter_id) REFERENCES users(id),
-- FOREIGN KEY(status_id) REFERENCES statuses(id)	  