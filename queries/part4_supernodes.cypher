// знайти вузли з великою кількістю ребер
MATCH (u:User)-[r:RATED]->()
RETURN u.userId AS nodeId, labels(u) AS nodeLabels, count(r) AS totalConnections
ORDER BY totalConnections DESC
LIMIT 10;

MATCH (m:Movie)-[i_g:IN_GENRE]->(g:Genre)
RETURN g.name AS Genre, labels(g) AS nodeLabels, count(i_g) AS totalConnections
ORDER BY totalConnections DESC
LIMIT 10;

MATCH (u:User)-[r:RATED]->(m:Movie)
RETURN m.title AS Movie, labels(m) AS nodeLabels, count(r) AS totalConnections
ORDER BY totalConnections DESC
LIMIT 10;