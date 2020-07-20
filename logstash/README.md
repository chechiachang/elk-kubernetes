Logstash
===

We use logstash to parse nginx message with grok piepeline

### Nginx grok

nginx.conf of nginx-ingress-controller
```
log_format upstreaminfo '$the_real_ip - [$the_real_ip] - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" $request_length $request_time [$proxy_upstream_name] $upstream_addr $upstream_response_length $upstream_response_time $upstream_status $req_id';
```

Nginx Output with responding Grok pattern. Use grok debugger to create one in kibana -> dev tools -> grok debugger
```
35.185.145.221 - [35.185.145.221] - - [26/Dec/2018:10:44:22 +0000] "GET /modules/actions/api?timestamp=1545821062&hash=e63ffc17319baa5524a7ad10dbb3c4be822c4e519d88efdae511116498d6c9e2 HTTP/1.1" 200 3 "-" "python-requests/2.18.4" 416 0.013 [default-app-server-80] 10.24.10.14:8080 3 0.014 200 67ce5290d19e39b2a6b614a617a1cd98

%{IPORHOST:[nginx][access][remote_ip]} - \[%{IPORHOST:[nginx][access][remote_ip_list]}\] - %{DATA:[nginx][access][user_name]} \[%{HTTPDATE:[nginx][access][time_local]}\] \"%{WORD:[nginx][access][method]} %{DATA:[nginx][access][url]} HTTP/%{NUMBER:[nginx][access][http_version]}\" %{NUMBER:[nginx][access][response_code]} %{NUMBER:[nginx][access][body_sent][bytes]} \"%{DATA:[nginx][access][referrer]}\" \"%{DATA:[nginx][access][user_agent_original]}\" %{NUMBER:[nginx][access][request_length]} %{NUMBER:[nginx][access][request_time]} \[%{DATA:[nginx][access][proxy_upstream_name]}\] %{DATA:[nginx][access][upstream_addr]} %{NUMBER:[nginx][access][upstream_response_length]} %{NUMBER:[nginx][access][upstream_response_time]} %{NUMBER:[nginx][access][upstream_status]} %{DATA:[nginx][access][req_id]}
```

