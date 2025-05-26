# docker compose up -d
# docker exec -i config1 mongosh < scripts/init-config-server.js
# docker exec -i shard2-1 mongosh --port 27018 < scripts/init-shard2.js
# docker exec -i shard3-1 mongosh --port 27018 < scripts/init-shard3.js
# docker exec -i shard1-1 mongosh --port 27018 < scripts/init-shard1.js
# docker exec -i projet-mongos mongosh < scripts/add-shards.js