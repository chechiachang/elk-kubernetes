Deploy GCE Beats
===

# Metricbeat
[https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-getting-started.html](https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-getting-started.html)
```
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-6.5.4-amd64.deb
sudo dpkg -i metricbeat-6.5.4-amd64.deb

metricbeat modules list
metricbeat modules enable system

vim /etc/metricbeat/metricbeat.yml

sudo service metricbeat start
tail -100 /var/log/metricbeat/metric/beat
```

Enable MySQL Modules if has a localhost mysql.
```
filebeat modules enable mysql

vim /etc/metricbeat/module.d/mysql.yml
sudo service metricbeat restart
```

# Filebeat

[https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html](https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-getting-started.html)

```
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.5.4-amd64.deb
sudo dpkg -i filebeat-6.5.4-amd64.deb

filebeat  modules list
filebeat modules enable system

vim /etc/filebeat/filebeat.yml
# Update cloud.id and cloud.auth

sudo service filebeat start
tail -100 /var/log/filebeat/filebeat
```

Enable Nginx Modules to collect log if has a localhost nginx.
```
filebeat modules enable mysql

vim /etc/metricbeat/module.d/mysql.yml
sudo service metricbeat restart
```


