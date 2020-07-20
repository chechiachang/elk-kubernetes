Filebeat
===

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
