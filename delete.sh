#!/bin/bash
# Delete elk beats from GKE

kubectl delete -f beats/filebeat
kubectl delete -f beats/metricbeat
kubectl delete ns elk
