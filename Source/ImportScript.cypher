// Import sample data
LOAD CSV WITH HEADERS FROM "https://github.com/andreiaverin/neo4j-recommender/raw/master/Source/SampleData.csv" AS line FIELDTERMINATOR ';'
MERGE (c:Customer { name:line.firstName + ' ' + line.lastName })
MERGE (p:Product { name:line.productName })
MERGE (cat:Category { name:line.categoryName })
MERGE (v:Vendor { name:line.vendorName }) 
WITH c, p, cat, v
MERGE (c)-[:BOUGHT]->(p) 
MERGE (p)-[:HAS_CAT]->(cat)
MERGE (p)-[:MADE_BY]->(v)
RETURN c, p, cat, v

// Remove all nodes and relationships
MATCH (n)
OPTIONAL MATCH (n)-[r]-()
DELETE n,r

// Get product recommendation
MATCH (c1:Customer)-[:BOUGHT]->(p1:Product)<-[:BOUGHT]-(c2:Customer)-[:BOUGHT]->(p2:Product)
WITH c1, c2, COUNT(p1) AS NrInCommon, COLLECT(p1) AS InCommon, p2
WHERE NOT((c1)-[:BOUGHT]->(p2)) AND NrInCommon > 4
RETURN c1.name AS Customer1, c2.name AS Customer2, 
	   [x IN InCommon | x.name] AS CommonProducts, 
	   p2.name AS Recommendation
ORDER BY c1.name ASC
LIMIT 20;
