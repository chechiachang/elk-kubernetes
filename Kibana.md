Kibana
===

# Check Activity

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
