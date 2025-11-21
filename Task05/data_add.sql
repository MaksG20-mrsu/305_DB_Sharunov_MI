INSERT INTO users (full_name, email, gender, birth_date, occupation_id) VALUES
('Maksim Sharunov', 'sharunovmax@mail.ru', 'male', '2005-06-07', (SELECT occupation_id FROM occupations WHERE name = 'student')),
('Artem Firstov', 'firstov@mail.ru', 'male', '2005-05-08', (SELECT occupation_id FROM occupations WHERE name = 'student')),
('Vladislav Chetaikin', 'winttovlad@mail.ru', 'male', '2005-04-04', (SELECT occupation_id FROM occupations WHERE name = 'student')),
('Igor Pyatkin', 'pyatkin@mail.ru', 'male', '2005-03-05', (SELECT occupation_id FROM occupations WHERE name = 'student')),
('Ilya Tulskov', 'ilya.tulskov@mail.ru', 'male', '2005-02-01', (SELECT occupation_id FROM occupations WHERE name = 'student'));

INSERT INTO movies (title, year) VALUES
('The Wolf of Wall Street', 2013),
('Legend', 2015),
('John Wick: Chapter 4', 2023);

INSERT INTO movie_genres (movie_id, genre_id) VALUES
((SELECT movie_id FROM movies WHERE title = 'The Wolf of Wall Street'), (SELECT genre_id FROM genres WHERE name = 'Drama')),
((SELECT movie_id FROM movies WHERE title = 'Legend'), (SELECT genre_id FROM genres WHERE name = 'Crime')),
((SELECT movie_id FROM movies WHERE title = 'John Wick: Chapter 4'), (SELECT genre_id FROM genres WHERE name = 'Action'));

INSERT INTO ratings (user_id, movie_id, rating, "timestamp") VALUES
((SELECT user_id FROM users WHERE email = 'sharunovmax@mail.ru'), (SELECT movie_id FROM movies WHERE title = 'The Wolf of Wall Street'), 5, strftime('%s', 'now')),
((SELECT user_id FROM users WHERE email = 'sharunovmax@mail.ru'), (SELECT movie_id FROM movies WHERE title = 'Legend'), 4.5, strftime('%s', 'now')),
((SELECT user_id FROM users WHERE email = 'sharunovmax@mail.ru'), (SELECT movie_id FROM movies WHERE title = 'John Wick: Chapter 4'), 4, strftime('%s', 'now'));