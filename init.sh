#!/bin/bash
# Apply elk beats to GKE
#
# Dependency:
#   Kubectl with GKE credentials
# Required Environment Varabales:
#   ELASTICSEARCH_HOST=
#   ELASTICSEARCH_PORT=
#   ELASTICSEARCH_USERNAME=
#   ELASTICSEARCH_PASSWORD=
#   ELASTIC_CLOUD_ID=
#   GKE_ADMIN_PASSWORD=

export ELASTICSEARCH_HOST=
export ELASTICSEARCH_PORT=
export ELASTICSEARCH_USERNAME=
export ELASTICSEARCH_PASSWORD=
export ELASTIC_CLOUD_ID=
export ELASTIC_CLOUD_AUTH=${ELASTICSEARCH_USERNAME}:${ELASTICSEARCH_PASSWORD}

# gcloud container clusters describe <cluster> --format "value(masterAuth.password)"
export GKE_ADMIN_PASSWORD=

# Creaet namespace
kubectl create ns elk

# Save secret in cluster
kubectl create secret generic elk-credentials \
  --namespace elk \
  --from-literal=ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST} \
  --from-literal=ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT} \
  --from-literal=ELASTICSEARCH_USERNAME=${ELASTICSEARCH_USERNAME} \
  --from-literal=ELASTICSEARCH_PASSWORD=${ELASTICSEARCH_PASSWORD} \
  --from-literal=ELASTIC_CLOUD_ID=${ELASTIC_CLOUD_ID} \
  --from-literal=ELASTIC_CLOUD_AUTH=${ELASTIC_CLOUD_AUTH}

# Might require admin permission depends on cluster rbac

# Clusterwide kubernetes state metrics
#kubectl apply --username admin --password ${GKE_ADMIN_PASSWORD} -f kube-state-metrics
# Logstash pipeline
#kubectl apply --username admin --password ${GKE_ADMIN_PASSWORD} -f logstash
# Filebeat for log collecting
kubectl apply --username admin --password ${GKE_ADMIN_PASSWORD} -f filebeat
# Metricbeat for metrics
kubectl apply --username admin --password ${GKE_ADMIN_PASSWORD} -f metricbeat
