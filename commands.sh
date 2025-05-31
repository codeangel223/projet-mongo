echo "Lancement des instances...."

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
docker exec -i projet-mongos mongosh -u root -p root < scripts/add-shards.js 


echo "Fin de montage des instaces."


# Les commandes d'activations du droit d'access au keyFile

docker exec -i projet-mongos chmod 400 ./data/db/keyFile

docker exec -i config1 chmod 400 ./data/db/keyFile
docker exec -i config2 chmod 400 ./data/db/keyFile
docker exec -i config3 chmod 400 ./data/db/keyFile

docker exec -i shard1-1 chmod 400 ./data/db/keyFile
docker exec -i shard1-2 chmod 400 ./data/db/keyFile
docker exec -i shard1-3 chmod 400 ./data/db/keyFile

docker exec -i shard2-1 chmod 400 ./data/db/keyFile
docker exec -i shard2-2 chmod 400 ./data/db/keyFile
docker exec -i shard2-3 chmod 400 ./data/db/keyFile

docker exec -i shard3-1 chmod 400 ./data/db/keyFile
docker exec -i shard3-2 chmod 400 ./data/db/keyFile
docker exec -i shard3-3 chmod 400 ./data/db/keyFile