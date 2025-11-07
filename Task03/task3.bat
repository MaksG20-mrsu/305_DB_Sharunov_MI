#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT m.title AS title, m.year AS year FROM movies m WHERE m.year IS NOT NULL AND EXISTS (SELECT 1 FROM ratings r WHERE r.movie_id = m.id) ORDER BY m.year, m.title LIMIT 10;"
echo " "

# 2
echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT id, name, register_date FROM users WHERE UPPER(TRIM(CASE WHEN INSTR(name, ' ') > 0 THEN SUBSTR(name, INSTR(name, ' ') + 1) ELSE name END)) LIKE 'A%%' ORDER BY register_date LIMIT 5;"
echo " "

# 3
echo "3. Имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать по имени эксперта, затем названию фильма и оценке. В списке оставить первые 50 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u.name AS expert, m.title AS title, m.year AS year, r.rating AS rating, date(r.timestamp, 'unixepoch') AS rated_at FROM ratings r JOIN users u ON u.id = r.user_id JOIN movies m ON m.id = r.movie_id ORDER BY u.name, m.title, r.rating LIMIT 50;"
echo " "

# 4
echo "4. Список фильмов с указанием тегов, которые были им присвоены пользователями. Сортировать по году выпуска, затем по названию фильма, затем по тегу. В списке оставить первые 40 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title AS title, m.year AS year, t.tag AS tag FROM tags t JOIN movies m ON m.id = t.movie_id WHERE m.year IS NOT NULL ORDER BY m.year, m.title, t.tag LIMIT 40;"
echo " "

# 5
echo "5. Вывести список самых свежих фильмов (все фильмы последнего года выпуска, имеющиеся в базе данных). Год определяется в запросе."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH mx AS (SELECT MAX(year) AS y FROM movies WHERE year IS NOT NULL) SELECT title, year FROM movies WHERE year = (SELECT y FROM mx) ORDER BY title;"
echo " "

# 6
echo "6. Найти все драмы, выпущенные после 2005 года, которые понравились женщинам (оценка не ниже 4.5). Для каждого фильма вывести название, год и количество таких оценок. Отсортировать по году и названию."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title AS title, m.year AS year, COUNT(*) AS likes_count FROM ratings r JOIN users u ON u.id = r.user_id JOIN movies m ON m.id = r.movie_id WHERE u.gender = 'female' AND r.rating >= 4.5 AND m.year > 2005 AND (m.genres LIKE '%%Drama%%' OR m.genres LIKE '%%drama%%') GROUP BY m.id, m.title, m.year ORDER BY m.year, m.title;"
echo " "

# 7
echo "7. Провести анализ востребованности ресурса - вывести количество пользователей, регистрировавшихся на сайте в каждом году. Найти, в каких годах регистрировалось больше всего и меньше всего пользователей."
echo --------------------------------------------------
echo "7.1 Количество регистраций по годам:"
sqlite3 movies_rating.db -box -echo "SELECT substr(register_date, 1, 4) AS year, COUNT(*) AS users_registered FROM users GROUP BY year ORDER BY year;"
echo " "
echo "7.2 Годы с максимумом и минимумом регистраций:"
sqlite3 movies_rating.db -box -echo "WITH reg AS (SELECT substr(register_date, 1, 4) AS year, COUNT(*) AS cnt FROM users GROUP BY year), mx AS (SELECT MAX(cnt) AS max_cnt FROM reg), mn AS (SELECT MIN(cnt) AS min_cnt FROM reg) SELECT 'max' AS kind, group_concat(year, ', ') AS years, (SELECT max_cnt FROM mx) AS registrations FROM reg WHERE cnt = (SELECT max_cnt FROM mx) UNION ALL SELECT 'min' AS kind, group_concat(year, ', ') AS years, (SELECT min_cnt FROM mn) AS registrations FROM reg WHERE cnt = (SELECT min_cnt FROM mn);"
echo " "

echo "Готово."
