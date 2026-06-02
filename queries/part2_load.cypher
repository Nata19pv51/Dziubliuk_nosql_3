// 1. Користувачі
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {userId: toInteger(row.userId)})
SET u.gender = row.gender,
    u.age = toInteger(row.age),
    u.occupation = row.occupation;

// 2. Фільми і Жанри
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET 
  m.year = toInteger(substring(row.title, size(row.title) - 5, 4)),
  m.title = trim(substring(row.title, 0, size(row.title) - 7))

WITH m, row
UNWIND split(row.genres, '|') AS genre
MERGE (g:Genre {name: genre})
MERGE (m)-[:IN_GENRE]->(g);


// 3. Індекси
CREATE CONSTRAINT unique_user_id IF NOT EXISTS FOR (u:User) REQUIRE u.userId IS UNIQUE;
CREATE CONSTRAINT unique_movie_id IF NOT EXISTS FOR (m:Movie) REQUIRE m.movieId IS UNIQUE;
CREATE INDEX index_movie_title IF NOT EXISTS FOR (m:Movie) ON (m.title);
CREATE INDEX index_genre_name IF NOT EXISTS FOR (g:Genre) ON (g.name);

// 4. Ребра
CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row RETURN row",
  "MATCH (u:User {userId: toInteger(row.userId)})
   MATCH (m:Movie {movieId: toInteger(row.movieId)})
   MERGE (u)-[r:RATED]->(m)
   SET r.rating = toInteger(row.rating), 
       r.timestamp = toInteger(row.timestamp)",
  {batchSize: 10000, parallel: false}
);