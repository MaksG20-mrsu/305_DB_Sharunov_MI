#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм (100 строк)"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u1.name AS user1, u2.name AS user2, m.title AS movie FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON u1.id = r1.user_id JOIN users u2 ON u2.id = r2.user_id JOIN movies m ON m.id = r1.movie_id LIMIT 100;"
echo " "

echo "2. 10 самых старых оценок от разных пользователей (название, имя, оценка, дата ГГГГ-ММ-ДД)"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH ranked AS (SELECT r.*, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp) AS rn FROM ratings r) SELECT m.title AS movie, u.name AS user, r.rating, date(r.timestamp,'unixepoch') AS rated_date FROM ranked r JOIN users u ON u.id = r.user_id JOIN movies m ON m.id = r.movie_id WHERE r.rn = 1 ORDER BY r.timestamp LIMIT 10;"
echo " "

echo "3. Фильмы с максимальным и минимальным средним рейтингом; колонка Рекомендуем: Да/Нет"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH agg AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies m JOIN ratings r ON r.movie_id = m.id GROUP BY m.id), bounds AS (SELECT MAX(avg_rating) AS max_avg, MIN(avg_rating) AS min_avg FROM agg) SELECT a.title, a.year, ROUND(a.avg_rating,2) AS avg_rating, CASE WHEN a.avg_rating = b.max_avg THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем' FROM agg a, bounds b WHERE a.avg_rating = b.max_avg OR a.avg_rating = b.min_avg ORDER BY a.year, a.title;"
echo " "

echo "4. Количество оценок и средняя оценка от мужчин в 2011-2014 годах"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(*) AS ratings_count, ROUND(AVG(r.rating),3) AS avg_rating FROM ratings r JOIN users u ON u.id = r.user_id WHERE u.gender = 'male' AND CAST(strftime('%Y', r.timestamp, 'unixepoch') AS INTEGER) BETWEEN 2011 AND 2014;"
echo " "

echo "5. Список фильмов со средней оценкой и количеством пользователей; сортировка по году и названию (20)"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, ROUND(AVG(r.rating),3) AS avg_rating, COUNT(DISTINCT r.user_id) AS users_count FROM movies m JOIN ratings r ON r.movie_id = m.id WHERE m.year IS NOT NULL AND m.year <> '' AND m.year <> 0 GROUP BY m.id, m.title, m.year ORDER BY m.year, m.title LIMIT 20;"
echo " "

echo "6. Самый распространенный жанр и количество фильмов в этом жанре (без отдельной таблицы жанров)"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split(id, rest, genre) AS (SELECT id, genres||'|', '' FROM movies UNION ALL SELECT id, substr(rest, instr(rest,'|')+1), substr(rest, 1, instr(rest,'|')-1) FROM split WHERE rest <> '' AND instr(rest,'|')>0) SELECT genre AS genre, COUNT(DISTINCT id) AS films FROM split WHERE genre <> '' GROUP BY genre ORDER BY films DESC, genre LIMIT 1;"
echo " "

echo "7. 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации'"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT CASE WHEN instr(name,' ') = 0 THEN name ELSE substr(name, instr(name,' ')+1) || ' ' || substr(name, 1, instr(name,' ')-1) END AS 'Фамилия Имя', register_date AS 'Дата регистрации' FROM users ORDER BY register_date DESC, id DESC LIMIT 10;"
echo " "

set BDAY_DD=29
set BDAY_MM=06

echo "8. Рекурсивный CTE: дни недели вашего дня рождения по годам"
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE years(y) AS (SELECT 1970 UNION ALL SELECT y+1 FROM years WHERE y < 2030) SELECT y AS year, date(printf('%%04d-%%02d-%%02d', y, %BDAY_MM%, %BDAY_DD%)) AS date, CASE strftime('%%w', printf('%%04d-%%02d-%%02d', y, %BDAY_MM%, %BDAY_DD%)) WHEN '0' THEN 'Воскресенье' WHEN '1' THEN 'Понедельник' WHEN '2' THEN 'Вторник' WHEN '3' THEN 'Среда' WHEN '4' THEN 'Четверг' WHEN '5' THEN 'Пятница' WHEN '6' THEN 'Суббота' END AS weekday FROM years;"
echo " "

echo "Готово."
