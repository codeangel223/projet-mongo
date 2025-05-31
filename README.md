# Projet MongoDB - Cluster Sharded

Ce projet implémente un cluster MongoDB shardé avec une architecture distribuée utilisant Docker Compose.

## Architecture Shardée MongoDB

Ce projet met en place une architecture MongoDB shardée complète avec les composants suivants :

### Services Docker Compose

Le fichier `docker-compose.yml` définit les services suivants :

1. **Config Servers (3 nœuds)**
   ```yaml
   config1, config2, config3:
     - Image: mongo
     - Configuration: /etc/mongod.yml
     - Volumes: 
       - Données persistantes
       - keyFile pour l'authentification
       - Fichier de configuration
   ```
   - Ces serveurs stockent les métadonnées du cluster
   - Forment un replica set pour la haute disponibilité
   - Gèrent la distribution des données entre les shards

2. **Shards (3 shards avec 3 répliques chacun)**
   ```yaml
   shard1-1, shard1-2, shard1-3:  # Premier shard
   shard2-1, shard2-2, shard2-3:  # Deuxième shard
   shard3-1, shard3-2, shard3-3:  # Troisième shard
   ```
   - Chaque shard est un replica set de 3 nœuds
   - Port par défaut: 27018
   - Stockage distribué des données
   - Haute disponibilité par réplication

3. **Mongos Router**
   ```yaml
   mongos:
     - Point d'entrée unique (port 27017)
     - Gère le routage des requêtes
     - Interface entre les applications et le cluster
   ```
   - Route les requêtes vers les shards appropriés
   - Cache les métadonnées des config servers
   - Point d'accès unique pour les applications

### Réseau et Volumes

- **Réseau**: `mongo-cluster` (bridge)
  - Communication interne entre tous les composants
  - Isolation du réseau

- **Volumes**:
  - Volumes persistants pour chaque nœud
  - Stockage des données et configurations
  - Isolation des données entre les conteneurs

### Sécurité

- **keyFile**: Authentification interne entre les nœuds
- **Permissions**: Configuration restrictive (chmod 400)
- **Authentification**: Utilisateurs MongoDB avec rôles appropriés

## Architecture du Cluster

Le cluster est composé des éléments suivants :

### 1. Config Servers (3 nœuds)
- `config1`, `config2`, `config3`
- Gèrent les métadonnées du cluster
- Assurent la haute disponibilité des configurations

### 2. Shards (3 répliques par shard)
- **Shard 1**: `shard1-1`, `shard1-2`, `shard1-3`
- **Shard 2**: `shard2-1`, `shard2-2`, `shard2-3`
- **Shard 3**: `shard3-1`, `shard3-2`, `shard3-3`
- Chaque shard est une réplique set pour la haute disponibilité

### 3. Mongos Router
- Instance `projet-mongos`
- Point d'entrée unique pour les applications
- Port exposé : 27017

## Structure des Fichiers

```
.
├── config/               # Fichiers de configuration
├── scripts/             # Scripts d'initialisation
├── docker-compose.yml   # Configuration Docker
├── commands.sh         # Script de déploiement
└── keyFile            # Fichier d'authentification
```

## Configuration de la Sécurité

### Génération de la Clé de Sécurité

Pour activer l'authentification entre les nœuds, vous devez d'abord générer une clé de sécurité :

```bash
# Génération d'une nouvelle clé de sécurité
openssl rand -base64 756 > keyFile
chmod 400 keyFile
```

### Activation de l'Authentification (Optionnel)

L'authentification est désactivée par défaut. Pour l'activer :

1. **Activer l'authentification dans les fichiers de configuration**
   - Décommenter les lignes `security.authorization: enabled` dans les fichiers :
     - `config/configsvr.yml`
     - `config/shard1.yml`
     - `config/shard2.yml`
     - `config/shard3.yml`
     - `config/mongos.yml`

2. **Créer les utilisateurs nécessaires**
   ```javascript
   use admin
   db.createUser({
     user: "root",
     pwd: "root",
     roles: [ { role: "root", db: "admin" } ]
   })
   ```

3. **Redémarrer les services**
   ```bash
   docker compose down
   docker compose up -d
   ```

## Configuration Initiale

Avant le premier démarrage du cluster, il est nécessaire de configurer l'authentification en suivant ces étapes :

1. **Désactiver l'authentification initiale**
   - Commenter les lignes `security.authorization: enabled` dans tous les fichiers de configuration dans le dossier `config/`
   - Cela permet de démarrer le cluster sans authentification pour créer les utilisateurs

2. **Démarrage initial et création des utilisateurs**
   - Lancer le cluster avec les commandes de `commands.sh`
   - Créer les utilisateurs nécessaires via mongosh
   - Exemple de création d'utilisateur root :
     ```javascript
     use admin
     db.createUser({
       user: "root",
       pwd: "root",
       roles: [ { role: "root", db: "admin" } ]
     })
     ```

3. **Activation de l'authentification**
   - Décommenter les lignes `security.authorization: enabled` dans tous les fichiers de configuration
   - Redémarrer tous les conteneurs :
     ```bash
     docker compose down
     docker compose up -d
     ```
   - Relancer les scripts d'initialisation si nécessaire

## Déploiement

Le script `commands.sh` gère le déploiement complet du cluster. Voici l'explication des commandes :

1. **Lancement des Config Servers**
   ```bash
   docker compose up -d config1 config2 config3
   ```
   - Démarre les 3 serveurs de configuration
   - Attente de 5 secondes pour l'initialisation

2. **Initialisation du Config Server**
   ```bash
   docker exec -i config1 mongosh < scripts/init-config-server.js
   ```
   - Configure le replica set des config servers

3. **Lancement des Shards**
   ```bash
   docker compose up -d shard1-1 shard1-2 shard1-3 shard2-1 shard2-2 shard2-3 shard3-1 shard3-2 shard3-3
   ```
   - Démarre tous les nœuds des shards

4. **Initialisation des Shards**
   ```bash
   docker exec -i shard1-1 mongosh --port 27018 < scripts/init-shard1.js
   docker exec -i shard2-1 mongosh --port 27018 < scripts/init-shard2.js
   docker exec -i shard3-1 mongosh --port 27018 < scripts/init-shard3.js
   ```
   - Configure chaque shard comme un replica set

5. **Lancement du Router**
   ```bash
   docker compose up -d mongos
   docker exec -i projet-mongos mongosh -u root -p root < scripts/add-shards.js
   ```
   - Démarre le router mongos
   - Ajoute les shards au cluster

6. **Configuration des Permissions**
   ```bash
   docker exec -i [container] chmod 400 ./data/db/keyFile
   ```
   - Configure les permissions du fichier keyFile pour tous les nœuds
   - Assure la sécurité de l'authentification

## Sécurité

- Utilisation d'un `keyFile` pour l'authentification interne
- Permissions restrictives (400) sur le keyFile
- Authentification requise pour les connexions

## Connexion

Pour se connecter au cluster :
```bash
mongosh -u root -p root
```

## Volumes

Le projet utilise des volumes Docker persistants pour :
- Données des config servers
- Données des shards
- Données du router

## Réseau

- Réseau bridge `mongo-cluster` pour la communication interne
- Port 27017 exposé pour les connexions externes sur le mongos