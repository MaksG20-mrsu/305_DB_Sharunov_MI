PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS users;

DROP TABLE IF EXISTS movies_raw;
DROP TABLE IF EXISTS ratings_raw;
DROP TABLE IF EXISTS tags_raw;
DROP TABLE IF EXISTS users_raw;

CREATE TABLE movies (
  id INTEGER PRIMARY KEY,
  title TEXT,
  year INTEGER,
  genres TEXT
);

CREATE TABLE ratings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  movie_id INTEGER,
  rating REAL,
  timestamp INTEGER
);

CREATE TABLE tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  movie_id INTEGER,
  tag TEXT,
  timestamp INTEGER
);

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name TEXT,
  email TEXT,
  gender TEXT,
  register_date TEXT,
  occupation TEXT
);

CREATE TABLE movies_raw (
  movieId TEXT,
  title TEXT,
  genres TEXT
);
CREATE TABLE ratings_raw (
  userId TEXT,
  movieId TEXT,
  rating TEXT,
  timestamp TEXT
);
CREATE TABLE tags_raw (
  userId TEXT,
  movieId TEXT,
  tag TEXT,
  timestamp TEXT
);
CREATE TABLE users_raw (
  id TEXT,
  name TEXT,
  email TEXT,
  gender TEXT,
  register_date TEXT,
  occupation TEXT
);

.mode csv
.separator ,
.import ../Task01/movies.csv movies_raw
.import ../Task01/ratings.csv ratings_raw
.import ../Task01/tags.csv tags_raw

.mode list
.separator |
.import ../Task01/users.txt users_raw

WITH cleaned AS (
  SELECT
    CAST(movieId AS INTEGER) AS id,
    TRIM(
      CASE
        WHEN SUBSTR(title, -1) = ')' AND SUBSTR(title, -6, 1) = '('
             AND SUBSTR(title, -5, 4) GLOB '[0-9][0-9][0-9][0-9]'
        THEN SUBSTR(title, 1, LENGTH(title) - 7)
        ELSE title
      END
    ) AS clean_title,
    CASE
      WHEN SUBSTR(title, -1) = ')' AND SUBSTR(title, -6, 1) = '('
           AND SUBSTR(title, -5, 4) GLOB '[0-9][0-9][0-9][0-9]'
      THEN CAST(SUBSTR(title, -5, 4) AS INTEGER)
      ELSE NULL
    END AS year,
    genres
  FROM movies_raw
  WHERE movieId <> 'movieId'
)
INSERT INTO movies(id, title, year, genres)
SELECT id, clean_title, year, genres FROM cleaned;

INSERT INTO ratings(user_id, movie_id, rating, timestamp)
SELECT CAST(userId AS INTEGER), CAST(movieId AS INTEGER), CAST(rating AS REAL), CAST(timestamp AS INTEGER)
FROM ratings_raw
WHERE userId <> 'userId';

INSERT INTO tags(user_id, movie_id, tag, timestamp)
SELECT CAST(userId AS INTEGER), CAST(movieId AS INTEGER), tag, CAST(timestamp AS INTEGER)
FROM tags_raw
WHERE userId <> 'userId';

INSERT INTO users(id, name, email, gender, register_date, occupation)
SELECT CAST(id AS INTEGER), name, email, gender, register_date, occupation
FROM users_raw
WHERE id <> 'id' OR id IS NULL;

DROP TABLE IF EXISTS movies_raw;
DROP TABLE IF EXISTS ratings_raw;
DROP TABLE IF EXISTS tags_raw;
DROP TABLE IF EXISTS users_raw;

COMMIT;

