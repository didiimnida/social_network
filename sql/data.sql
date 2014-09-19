INSERT INTO
    users (email, password, username, interests, mobile, picture)
VALUES
    ('diana@gmail.com', 'a', 'Diana Hilton', 'I am a web developer!', '8165171305', 'http://www.dianahilton.com/wp-content/uploads/2014/09/diana2-e1411090712935.jpg'),
    ('grace@gmail.com', 'a', 'Grace Hopper', 'Computer Scientist', '8165171305', 'http://www.dianahilton.com/wp-content/uploads/2014/09/hopper-e1411090894202.jpg'),
    ('max@gmail.com', 'a', 'Max Cantor', 'Programmer. Instructor. NYC.', '8165171305', 'http://www.dianahilton.com/wp-content/uploads/2014/09/max-e1411090884662.png'),
    ('albert@gmail.com', 'a', 'Albert Einstein', 'I am a physicist.', '8165171305', 'http://www.dianahilton.com/wp-content/uploads/2014/09/biggereinstein-e1411090591720.jpg')
;

INSERT INTO
    statuses (author_id, status, date)
VALUES
    (1, 'I need to do some TDD.', "2014-09-15 01:01:43"),
    (1, 'It is difficult to join/reference database tables without object relational mapping.', "2014-09-15 09:01:44"),
    (2, 'There is a bug in my computer?', "2014-09-16 06:01:45"),
    (4, 'The true sign of intelligence is not knowledge but imagination.', "2014-09-16 10:01:46"),
    (3, 'I am going to torture my GA students today! Muwahaha.', "2014-09-17 15:01:47"),
    (1, 'If you want to link to the same action from multiple views, do not try to redirect or you will get stuck in a redirect loop.  Use a variable and render the page again.', "2014-09-17 17:01:48"),
    (1, 'Implementation of the Twilio API was quick, but cannot send to a user number without verifying through Twilio first. Freemium.', "2014-09-17 18:01:49"),
    (1, 'Oh, no...I really need to add in the network features.  This is a really interesting mapping/joining problem.', "2014-09-17 00:01:50"),
    (1, 'My biggest problem is that I did not have a good mental model in my head for the App class so made use of local variables instead of cookies.', "2014-09-18 16:01:50")
;

INSERT INTO 
    comments (commenter_id, status_id, comment, date)
VALUES
    (2, 1, 'Test. Test. And test again!', "2014-09-17 01:02:43"),
    (4, 3, 'Squash it!', "2014-09-17 01:02:43"),
    (3, 1, 'What is TDD? LOLOLOL.', "2014-09-17 09:02:44"),
    (1, 4, 'I cannot imagine a world without the internet...', "2014-09-18 06:02:45"),
    (2, 5, 'Get them, Max!', "2014-09-18 06:02:45"),
    (1, 5, 'Noooooo.', "2014-09-18 06:02:45")
;

INSERT INTO
    friends (request_id, accept_id)
VALUES
    (1,2),
    (1,3),
    (1,4),
    (2,3),
    (2,4)
;

