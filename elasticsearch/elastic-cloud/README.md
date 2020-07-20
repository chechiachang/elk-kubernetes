Elastic Cloud
===

# Deploy Elastic Cloud deployment

### Login to Elastic Cloud

1. Login with Elastic Cloud Master username/password
[https://cloud.elastic.co](https://cloud.elastic.co)
2. Create a ELK deployment cluster on elastic cloud
3. Check ELK deployment status on Activity
4. Get elasticsearch url and kibana url, username, and password for each deployment

### Check Status on Kibana

1. Get kibana url from Elastic Cloud
2. Login with deployment username/password. Not the elastic cloud master password. Use the deployment-specific password.

---

# Connect Elasticsearch (Optional)

Use SQL Client of Elasticsearch
```
curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.3.tar.gz
tar -xvf elasticsearch-6.5.3.tar.gz
rm elasticsearch-6.5.3.tar.gz
cd elasticsearch-6.5.3
./bin/elasticsearch-sql-cli https://<username>:<password>@<es-url>:<es-port>
```

