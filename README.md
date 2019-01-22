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

### Connect Elasticsearch (Optional)

Use SQL Client of Elasticsearch
```
curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.3.tar.gz
tar -xvf elasticsearch-6.5.3.tar.gz
rm elasticsearch-6.5.3.tar.gz
cd elasticsearch-6.5.3
./bin/elasticsearch-sql-cli https://<username>:<password>@<es-url>:<es-port>
```

---

# Deploy beats: quick start

```
# Edit authentication
vim init.sh

# Auth for kubectl
gcloud auth activate-service-account --key-file /home/circleci/gcloud-service-key.json
gcloud container clusters get-credentials ${GKE_CLUSTER_NAME}
./init.sh
```

---

# Deploy beats to collect data

We use following components to collect/process data from instances and then send data to elasticsearch.

- metricbeat
  - collects k8s system metrics(cpu, memory,...) for each node as daemonsets
  - collects k8s cluster wide state (like pod state) through k8s-state-metrics as a deployment
  - runs as a systemctl service if is on a standalone GCE instance
- filebeat
  - tails logfiles from each node as daemonsets
  - tails container stdout and stderr with docker module
  - collects history log if possible
  - runs as a systemctl service if is on a standalone GCE instance
- logstash
  - accept data from beats, parse / enhance data, and send to elasticsearch
  - Current use cases:
    - Accept nginx log data from nginx-filebeat -> parse nginx message in pipeline
    - Accept app-server log data from app-filebeat -> parse server message in pipeline 

---

# Deploy GKE Beats

We deploy following 

./elk/gke/metricbeats/daemonsets
./elk/gke/logstash/deployment
./elk/gke/filebeats/nginx-deployment
./elk/gke/filebeats/server-daemonsets

### Logstash

We use logstash to parse nginx message with grok piepeline

nginx.conf of nginx-ingress-controller
```
log_format upstreaminfo '$the_real_ip - [$the_real_ip] - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $request_length $request_time [$proxy_upstream_name] $upstream_addr $upstream_response_length $upstream_response_time $upstream_status $req_id';
```

Nginx Output with responding Grok pattern. Use grok debugger to create one in kibana -> dev tools -> grok debugger
```
35.185.145.221 - [35.185.145.221] - - [26/Dec/2018:10:44:22 +0000] "GET /modules/actions/api?timestamp=1545821062&hash=e63ffc17319baa5524a7ad10dbb3c4be822c4e519d88efdae511116498d6c9e2 HTTP/1.1" 200 3 "-" "python-requests/2.18.4" 416 0.013 [default-app-server-80] 10.24.10.14:8080 3 0.014 200 67ce5290d19e39b2a6b614a617a1cd98

%{IPORHOST:[nginx][access][remote_ip]} - \[%{IPORHOST:[nginx][access][remote_ip_list]}\] - %{DATA:[nginx][access][user_name]} \[%{HTTPDATE:[nginx][access][time_local]}\] \"%{WORD:[nginx][access][method]} %{DATA:[nginx][access][url]} HTTP/%{NUMBER:[nginx][access][http_version]}\" %{NUMBER:[nginx][access][response_code]} %{NUMBER:[nginx][access][body_sent][bytes]} \"%{DATA:[nginx][access][referrer]}\" \"%{DATA:[nginx][access][user_agent_original]}\" %{NUMBER:[nginx][access][request_length]} %{NUMBER:[nginx][access][request_time]} \[%{DATA:[nginx][access][proxy_upstream_name]}\] %{DATA:[nginx][access][upstream_addr]} %{NUMBER:[nginx][access][upstream_response_length]} %{NUMBER:[nginx][access][upstream_response_time]} %{NUMBER:[nginx][access][upstream_status]} %{DATA:[nginx][access][req_id]}
```

### Check Activity

1. Config index pattern to match indices in elasticsearch
2. View data with Kibana Discover. 
3. Check Beats Log for each beats pod.

# Kibana Config

Kibana is the integrated tool to navigate Elastic Stack  and visulize data

1. Preview raw data in Discover
2. Visualize data by charts with Visualize
3. Create collect visualize with Dashboard
4. Create permalink for bashboards

# Kibana Discover

1. Choose interesting index pettern
2. Apply filters to select data

### GKE beats vs GCE beats

```
_exists_:kubernetes.*

_exists_:kubernetes.node.name
!_exists_:kubernetes.node.name
```

### GKE cluster

```
kubernetes.node.name:*gke-my-cluster*
```

### GKE container

```
kubernetes.container.name:*nginx*
```

### Metrics Modules

```
!_exists_:metricset.moule
metricset.module:system
metricset.module:kubernetes
```

### Filter by metricset.name

Metrics from nodes

metricset.name:
- container
- volume
- network
- pod
- process
- filesystem
- system
- node
- process_summary
- cpu
- load
- memory
- fsstat

States from kube-system-metrics (cluster state)

metricset.name:
- state_replicaset
- state_pod
- state_container
- state_deployment
- state_node
- events

### Visualize

1. State metrics
2. Node resource metrics
2. State Pod 

---

# Update Elasticsearch cluster

1. Modify config.yml of Elasticsearch cluster
2. Elastic cloud performs grow and shink config
3. Double instances number 
4. Waiting cluster instances ready
5. Migrating shard data
6. Delete old instances

The whole process took about 30 mins with a 2-node cluster
