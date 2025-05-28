echo "Lunch cluster started...."

docker compose up -d config1 config2 config3
sleep 5
docker exec -i config1 mongosh < scripts/init-config-server.js

docker compose up -d shard1-1 shard1-2 shard1-3 shard2-1 shard2-2 shard2-3 shard3-1 shard3-2 shard3-3
sleep 5
docker exec -i shard1-1 mongosh --port 27018 < scripts/init-shard1.js
sleep 2
docker exec -i shard2-1 mongosh --port 27018 < scripts/init-shard2.js
sleep 2
docker exec -i shard3-1 mongosh --port 27018 < scripts/init-shard3.js


docker compose up -d mongos
sleep 5
docker exec -i projet-mongos mongosh < scripts/add-shards.js


echo "End."

# rm -rf shard1/ shard2/ shard3/ configsvr mongos
# docker-compose down