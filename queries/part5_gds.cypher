// 5.1.
// Крок 1: матеріалізуємо ребра фільм-фільм через спільних користувачів
MATCH (m1:Movie)<-[r1:RATED]-(u:User)-[r2:RATED]->(m2:Movie)
WHERE r1.rating >= 4 AND r2.rating >= 4 AND id(m1) < id(m2)
WITH m1, m2, count(u) AS weight
WHERE size([(m1)<-[:RATED]-() | 1]) > 20
  AND size([(m2)<-[:RATED]-() | 1]) > 20
WITH m1, m2, weight
ORDER BY weight DESC
LIMIT 50000
MERGE (m1)-[co:CO_RATED]-(m2)
SET co.weight = weight;

// Крок 2: створюємо проєкцію на основі матеріалізованих ребер
CALL gds.graph.project(
  'movieGraph',
  'Movie',
  { CO_RATED: { orientation: 'UNDIRECTED', properties: 'weight' } }
)
YIELD graphName, nodeCount, relationshipCount;

// МІЙ КОД
CALL gds.pageRank.stream('movieGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).title AS movieTitle, round(score, 2) AS score
ORDER BY score DESC;

// Крок 4: видаляємо проєкцію та тимчасові ребра
CALL gds.graph.drop('movieGraph');
MATCH ()-[co:CO_RATED]-() DELETE co;



// 5.2.
// Крок 1: матеріалізуємо ребра користувач-користувач через спільні фільми
MATCH (u1:User)-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User)
WHERE r1.rating = 5 AND r2.rating = 5 AND id(u1) < id(u2)
WITH u1, u2, count(m) AS weight
WITH u1, u2, weight
ORDER BY weight DESC
LIMIT 50000
MERGE (u1)-[sim:SIMILAR]-(u2)
SET sim.weight = weight;

// Крок 2: створюємо проєкцію
CALL gds.graph.project(
  'userSimilarity',
  'User',
  { SIMILAR: { orientation: 'UNDIRECTED', properties: 'weight' } }
)
YIELD graphName, nodeCount, relationshipCount;

// МІЙ КОД
CALL gds.louvain.stream('userSimilarity')
YIELD nodeId, communityId

WITH communityId, gds.util.asNode(nodeId) AS member

// Знаходимо кількість користувачів в спільноті і створюємо список користувачів
WITH communityId, count(member) AS sizeCommunity, collect(member) AS membersCommunity
ORDER BY sizeCommunity DESC
LIMIT 10

// Розпаковуємо масив користувачів і дивимось їхні фільми
UNWIND(membersCommunity) AS user
MATCH (g:Genre)<-[:IN_GENRE]-(m:Movie)<-[r:RATED]-(user)
WHERE r.rating >= 4

// Рахуємо кількість оцінювань (вище 4) для кожного жанру у спільноті
WITH communityId, sizeCommunity, g.name AS genre, count(r) AS countRating
ORDER BY communityId, countRating DESC

// Виводимо результат, сортуємо за розміром спільноти
WITH communityId, sizeCommunity, collect(genre)[0..3] as topGenres
RETURN
    communityId,
    sizeCommunity,
    topGenres
ORDER BY sizeCommunity DESC;

// Крок 5: видаляємо проєкцію та тимчасові ребра
CALL gds.graph.drop('userSimilarity');
MATCH ()-[sim:SIMILAR]-() DELETE sim;


WITH gds.util.asNode(nodeId) AS u, communityId
MATCH (g:Genre)<-[:IN_GENRE]-(m:Movie)<-[r:RATED]-(u)
WITH collect(u.userId) AS communityMembers, collect(g), communityId
WHERE r.rating = maxRating
WITH communityId, communityMembers, collect(g.name) AS genreCommunity