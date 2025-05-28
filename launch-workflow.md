# Create volumes

bash```
mkdir -p configsvr shard1/shard1-{1,2,3} shard2/shard2-{1,2,3} shard3/shard3-{1,2,3}

````

# 1. Lancer tous les conteneurs

```bash
docker compose up -d
````

# 2. Initialiser le replicaSet config server

```bash
docker exec -i config1 mongosh < scripts/init-config-server.js
```

# 3. Initialiser les shards

```bash
docker exec -i shard2-1 mongosh --port 27018 < scripts/init-shard2.js
docker exec -i shard3-1 mongosh --port 27018 < scripts/init-shard3.js
docker exec -i shard1-1 mongosh --port 27018 < scripts/init-shard1.js
```

# 4. Ajouter les shards dans Mongos

```bash
docker exec -i projet-mongos mongosh < scripts/add-shards.js
```
