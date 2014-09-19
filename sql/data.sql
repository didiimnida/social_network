INSERT INTO
    users (email, password, username, interests, mobile, picture)
VALUES
    ('diana@coolapp.com', 'a', 'Diana Hilton', 'Interests: Web Development -- Biophysics -- Scientific Writing -- Asian Languages -- Education -- Engineering -- Entrepreneurship', '8165171305', 'http://www.dianahilton.com/wp-content/uploads/2014/09/diana2-e1411090712935.jpg'),
    ('grace@coolapp.com', 'a', 'Grace Hopper', 'Grace Hopper was an American computer scientist and United States Navy rear admiral.  A pioneer in the field, she was one of the first programmers of the Harvard Mark I computer, invented the first compiler for a computer programming language and popularized the idea of machine-independent programming languages, which led to the development of COBOL.', '8165171305', 'http://www.dianahilton.com/wp-content/uploads/2014/09/hopper-e1411090894202.jpg'),
    ('max@coolapp.com', 'a', 'Max Cantor', 'Programmer. Instructor. ', '9259229516', 'http://www.dianahilton.com/wp-content/uploads/2014/09/max-e1411090884662.png'),
    ('albert@coolapp.com', 'a', 'Albert Einstein', 'Any intelligent fool can make things bigger, more complex, and more violent. It takes a touch of genius -- and a lot of courage -- to move in the opposite direction.', '9259229516', 'http://www.dianahilton.com/wp-content/uploads/2014/09/biggereinstein-e1411090591720.jpg')
;

INSERT INTO
    statuses (author_id, status, date)
VALUES
    (1, 'I need to do some TDD.', "2014-09-15 01:01:43"),
    (1, 'It is difficult to join/reference database tables without object relational mapping.', "2014-09-15 09:01:44"),
    (2, 'There is a bug in my computer.', "2014-09-16 06:01:45"),
    (4, 'The true sign of intelligence is not knowledge but imagination.', "2014-09-16 10:01:46"),
    (3, 'I am going to torture my GA students today! Muwahaha.', "2014-09-17 15:01:47"),
    (1, 'If you want to link to the same action from multiple views, do not try to redirect or you will get stuck in a redirect loop.  Use a variable and render the page again.', "2014-09-17 17:01:48"),
    (1, 'Implementation of the Twilio API was quick, but cannot send to a user number without verifying through Twilio first. Freemium.', "2014-09-17 18:01:49"),
    (1, 'I need to add in a join table for friendships.  This is an interesting bidirectional network mapping problem.', "2014-09-17 22:01:50"),
    (1, 'My biggest problem is that I did not have a good mental model in my head for the App class so made use of local variables instead of cookies.', "2014-09-18 16:01:50")
;

INSERT INTO 
    comments (commenter_id, status_id, comment, date)
VALUES
    (2, 1, 'Test. Test. And test again!', "2014-09-17 01:02:43"),
    (4, 3, 'Kill it!', "2014-09-17 01:02:43"),
    (3, 1, 'I love TDD!!!', "2014-09-17 09:02:44"),
    (1, 4, 'I cannot imagine a world without the internet...', "2014-09-18 06:02:45"),
    (2, 5, 'Take it to the max, Max!', "2014-09-18 06:02:48"),
    (1, 5, 'Boo.', "2014-09-18 06:07:45"),
    (3, 9, 'Did you ask the rubber duck for help?', '2014-09-19 00:02:45'),
    (4, 7, 'Need those dolla, dolla bills, girl!', '2014-09-19 00:02:45')
;

INSERT INTO
    requests (requester_id, accepter_id)
VALUES
    (3,4)
;

INSERT INTO
    friends (request_id, accept_id)
VALUES
    (1,2),
    (2,1),
    (1,3),
    (3,1),
    (1,4),
    (4,1),
    (2,3),
    (3,2),
    (2,4),
    (4,2)
;



