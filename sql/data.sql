INSERT INTO
    users (email, password, username, interests, mobile)
VALUES
    ('diana@gmail.com', 'a', 'Diana Hilton', 'I am a web developer.', '8165171305'),
    ('hari@gmail.com', 'a', 'Hari Viswanathan', 'I am the husband of Diana.', '8165171305'),
    ('max@gmail.com', 'a', 'Max Cantor', 'I am an instructor at GA!', '8165171305'),
    ('albert@gmail.com', 'a', 'Albert Einstein', 'I am a physicist.', '8165171305')
;

INSERT INTO
    statuses (author_id, status, date)
VALUES
    (1, 'I need to do some TDD.', "2014-09-15 01:01:43"),
    (3, 'The job interview went really well.', "2014-09-15 09:01:44"),
    (2, 'I do not like burritos!', "2014-09-16 06:01:45"),
    (4, 'I am going to Hawaii next week! So excited.', "2014-09-16 10:01:46"),
    (1, 'I like burritos.', "2014-09-17 15:01:47"),
    (1, 'I think I am going to do a bootcamp...', "2014-09-17 17:01:48"),
    (2, 'How do I set the date?', "2014-09-17 18:01:49"),
    (3, 'Oh, no...I really need to add in network features.', "2014-09-17 00:01:50")
;

INSERT INTO 
	comments (commenter_id, status_id, comment, date)
VALUES
	(1, 2, 'Congratulations on the interview!', "2014-09-17 01:02:43"),
	(1, 3, 'You just need to get used to Mexican food.', "2014-09-17 01:02:43"),
    (2, 1, 'What is TDD?', "2014-09-17 09:02:44"),
    (2, 2, 'What was the interview for?', "2014-09-18 06:02:45"),
    (3, 2, 'I usually hate interviews.', "2014-09-18 06:02:45"),
    (4, 2, 'I hope you get it.', "2014-09-18 06:02:45")
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

