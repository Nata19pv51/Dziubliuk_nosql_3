// Запит 1. Знайти всі фільми жанру «Thriller» із середнім рейтингом вище 4.0:
MATCH (t:Genre {name: "Thriller"})<-[:IN_GENRE]-(m:Movie)<-[r:RATED]-(u:User)
WITH m, avg(r.rating) AS avg_rating
WHERE avg_rating > 4.0
RETURN m.title AS Movie, round(avg_rating, 2) AS Rating
ORDER BY Rating DESC;

// Запит 2. Знайти користувачів, які поставили оцінку 5 більш ніж 50 фільмам:
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE r.rating = 5
WITH u, count(m) AS num_movies
WHERE num_movies > 50
RETURN u.userId AS UserID, num_movies AS Count_Movies
ORDER BY Count_Movies DESC;

// Запит 3. Знайти фільми, які обидва користувачі (наприклад, userId=1 і userId=2) оцінили високо (рейтинг ≥ 4):
MATCH(u1:User{userId:1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User{userId:2})
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN m.title AS Movie, r1.rating AS Rating_1, r2.rating AS Rating_2;

// Запит 4. Знайти жанри, чиї фільми стабільно отримують високі оцінки — середній рейтинг і кількість оцінок:
MATCH (g:Genre)<-[:IN_GENRE]-(m:Movie)<-[r:RATED]-()
WITH g, avg(r.rating) AS avg_rating, count(r) AS num_ratings
ORDER BY avg_rating DESC, num_ratings DESC
LIMIT 5
RETURN g.name AS Genre, round(avg_rating, 2) AS Avg_Rating, num_ratings AS Num_Ratings;

// Запит 5. Рекомендація «користувачі зі схожими смаками також дивилися»: для заданого користувача знайти фільми, які він ще не дивився, але високо оцінили користувачі з подібними смаками:
MATCH (u1:User {userId: 1})-[r1:RATED]->(m1:Movie)
WHERE r1.rating > 4
MATCH (u1:User)-[:RATED]->(m1)<-[r2:RATED]-(u2:User)
WHERE r2.rating > 4
MATCH (u2)-[r3:RATED]->(m_rec:Movie)
WHERE r3.rating > 4 AND NOT EXISTS {
  MATCH (u1)-[:RATED]->(m_rec)
}
RETURN m_rec.title AS Recommended_Movie,
        count(u2) AS Count_Recommendations,
        round(avg(r3.rating), 2) AS Avg_Rating
ORDER BY Count_Recommendations DESC, Avg_Rating DESC
LIMIT 5;

// Запит 6. Знайти найкоротший ланцюжок зв’язку між двома користувачами через спільні фільми:
MATCH (u1:User {userId: 1}), (u2:User {userId: 12})
MATCH p = shortestPath((u1)-[:RATED*..10]-(u2))
RETURN [node IN nodes(p) | coalesce(node.title, "User: " + node.userId)] AS Connection_Chain, 
        length(p) AS Length_Path;

