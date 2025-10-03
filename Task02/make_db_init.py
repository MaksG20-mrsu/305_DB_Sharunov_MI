import csv
import re
import os

def generate_sql_script():
    with open('db_init.sql', 'w', encoding='utf-8') as f:
        f.write("DROP TABLE IF EXISTS movies;\n")
        f.write("DROP TABLE IF EXISTS ratings;\n")
        f.write("DROP TABLE IF EXISTS tags;\n")
        f.write("DROP TABLE IF EXISTS users;\n")
        f.write("\n")

        f.write("""
        CREATE TABLE movies (
            id INTEGER PRIMARY KEY,
            title TEXT,
            year INTEGER,
            genres TEXT
        );
        """)
        f.write("""
        CREATE TABLE ratings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            movie_id INTEGER,
            rating REAL,
            timestamp INTEGER
        );
        """)
        f.write("""
        CREATE TABLE tags (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            movie_id INTEGER,
            tag TEXT,
            timestamp INTEGER
        );
        """)
        f.write("""
        CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            name TEXT,
            email TEXT,
            gender TEXT,
            register_date TEXT,
            occupation TEXT
        );
        """)
        f.write("\n")

        with open(os.path.join('dataset', 'movies.csv'), 'r', encoding='utf-8') as movies_file:
            reader = csv.reader(movies_file)
            next(reader)
            for row in reader:
                movie_id, title, genres = row
                year_match = re.search(r'\((\d{4})\)', title)
                year = 'NULL'
                clean_title = title
                if year_match:
                    year = int(year_match.group(1))
                    clean_title = title[:year_match.start()].strip()

                clean_title = clean_title.replace("'", "''")
                f.write(f"INSERT INTO movies (id, title, year, genres) VALUES ({movie_id}, '{clean_title}', {year}, '{genres}');\n")

        with open(os.path.join('dataset', 'ratings.csv'), 'r', encoding='utf-8') as ratings_file:
            reader = csv.reader(ratings_file)
            next(reader)
            for row in reader:
                user_id, movie_id, rating, timestamp = row
                f.write(f"INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES ({user_id}, {movie_id}, {rating}, {timestamp});\n")

        with open(os.path.join('dataset', 'tags.csv'), 'r', encoding='utf-8') as tags_file:
            reader = csv.reader(tags_file)
            next(reader)
            for row in reader:
                user_id, movie_id, tag, timestamp = row
                tag = tag.replace("'", "''")
                f.write(f"INSERT INTO tags (user_id, movie_id, tag, timestamp) VALUES ({user_id}, {movie_id}, '{tag}', {timestamp});\n")

        with open(os.path.join('dataset', 'users.txt'), 'r', encoding='utf-8') as users_file:
            for line in users_file:
                parts = line.strip().split('|')
                user_id, name, email, gender, register_date, occupation = parts
                name = name.replace("'", "''")
                f.write(f"INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ({user_id}, '{name}', '{email}', '{gender}', '{register_date}', '{occupation}');\n")

if __name__ == "__main__":
    generate_sql_script()