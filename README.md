Deploy ELK Stack to Monitor Services on Kubernetes
===

Just a normal user promoting this fantastic tool stack.

In this project, we deploy elk to monitor metrics of
- kubernetes cluster metrics
- kubernetes nodes metrics

In this project, we deploy elk to collect log of
- nginx-ingress-controller
- a deployment named app-server

Issues and PRs are welcome.

---

# Deploy Elasticsearch cluster

Choose your elasticsearch deployment

- [Host on GKE with helm](elasticsearch/helm)
- [Use Elastic Cloud](elasticsearch/elastic-cloud)
- Deploy on Compute Engine(VMs)

# Install monitoring services

- GKE
  - kube-state-metrics
  - Logstash
  - filebeat
  - metricbeat
- GCE
  - filebeat
  - metricbeat

---

# Install services

Save secret in cluster
```
ELASTICSEARCH_HOST=
ELASTICSEARCH_PORT=
ELASTICSEARCH_USERNAME=
ELASTICSEARCH_PASSWORD=
ELASTIC_CLOUD_ID=
ELASTIC_CLOUD_AUTH=${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}

kubectl create ns elk

kubectl create secret generic elk-credentials \
  --namespace elk \
  --from-literal=ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST} \
  --from-literal=ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT} \
  --from-literal=ELASTICSEARCH_USERNAME=${ELASTICSEARCH_USERNAME} \
  --from-literal=ELASTICSEARCH_PASSWORD=${ELASTICSEARCH_PASSWORD} \
  --from-literal=ELASTIC_CLOUD_ID=${ELASTIC_CLOUD_ID} \
  --from-literal=ELASTIC_CLOUD_AUTH=${ELASTIC_CLOUD_AUTH}
```

Auth for kubectl
```
gcloud auth activate-service-account --key-file /home/circleci/gcloud-service-key.json
gcloud container clusters get-credentials ${GKE_CLUSTER_NAME}
```

Apply services
```
# Might require admin permission depends on cluster rbac
# gcloud container clusters describe <cluster> --format "value(masterAuth.password)"
GKE_ADMIN_PASSWORD=

# Clusterwide kubernetes state metrics
kubectl apply --username admin --password ${GKE_ADMIN_PASSWORD} -f kube-state-metrics
# Logstash pipeline
kubectl apply --username admin --password ${GKE_ADMIN_PASSWORD} -f logstash
# Filebeat for log collecting
kubectl apply --username admin --password ${GKE_ADMIN_PASSWORD} -f filebeat
# Metricbeat for metrics
kubectl apply --username admin --password ${GKE_ADMIN_PASSWORD} -f metricbeat
```

---

# Update Elasticsearch cluster

1. Modify config.yml of Elasticsearch cluster
2. Elastic cloud performs grow and shink config
3. Double instances number 
4. Waiting cluster instances ready
5. Migrating shard data
6. Delete old instances

The whole process took about 30 mins with a 2-node cluster

---

# Delete elk beats from GKE

kubectl delete -f beats/filebeat
kubectl delete -f beats/metricbeat
kubectl delete ns elk
