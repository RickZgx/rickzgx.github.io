---
title: Hey工具魔改
date: 2022-01-20 14:01:00 Z
categories:
- OpenSource
tags:
- Golang
- Tool
comments: true
---

* content
{:toc}

hey是 Google一女工程师（现在在aws）使用 Go 语言开发的类似 apache ab 的性能测试工具。相比 ab，boom跨平台性更好，而且更容易安装。

## hey manual

```bash
./bin/hey_linux_amd64 -h
flag needs an argument: -h
Usage: hey [options...] <url>

Options:
  -n  Number of requests to run. Default is 200.
  -c  Number of workers to run concurrently. Total number of requests cannot
      be smaller than the concurrency level. Default is 50.
  -q  Rate limit, in queries per second (QPS) per worker. Default is no rate limit.
  -z  Duration of application to send requests. When duration is reached,
      application stops and exits. If duration is specified, n is ignored.
      Examples: -z 10s -z 3m.
  -o  Output type. If none provided, a summary is printed.
      "csv" is the only supported alternative. Dumps the response
      metrics in comma-separated values format.

  -m  HTTP method, one of GET, POST, PUT, DELETE, HEAD, OPTIONS.
  -H  Custom HTTP header. You can specify as many as needed by repeating the flag.
      For example, -H "Accept: text/html" -H "Content-Type: application/xml" .
  -t  Timeout for each request in seconds. Default is 20, use 0 for infinite.
  -A  HTTP Accept header.
  -d  HTTP request body.
  -D  HTTP request body from file. For example, /home/user/file.txt or ./file.txt.
  -T  Content-type, defaults to "text/html".
  -U  User-Agent, defaults to version "hey/0.0.1".
  -a  Basic authentication, username:password.
  -x  HTTP Proxy address as host:port.
  -h2 Enable HTTP/2.

  -host HTTP Host header.

  -disable-compression  Disable compression.
  -disable-keepalive    Disable keep-alive, prevents re-use of TCP
                        connections between different HTTP requests.
  -disable-redirects    Disable following of HTTP redirects
  -cpus                 Number of used cpu cores.
                        (default for current machine is 8 cores)
```

举几个例子

` ./bin/hey_linux_amd64 -z 10m  http://127.0.0.1:50000`

持续发10min无限发压

` ./bin/hey_linux_amd64 -c 10 -n 10000  http://127.0.0.1:50000`

10并发发10000个请求



代码写的是短小精悍，但唯一是不足是没法看指标的一个变化曲线，比如我要看服务的性能瓶颈，到达什么量级系统压不上去、请求量多少时候机器性能有问题等。因此接入[Prometheus](https://prometheus.io/) + [Grafana](https://grafana.com/)十分有必要的。



Prometheus 是一个开源的服务监控系统和时间序列数据库， 提供监控数据存储，展示，告警等功能。



Grafana 是一个用于监控指标分析和图表展示的工具， 后端支持 Graphite, InfluxDB & Prometheus & Open-falcon等， 它是一个流行的监控组件， 目前在各大中小型公司中广泛应用



修改patch

https://github.com/zgxme/hey/commit/15e4febda47749aa3683820d705be237ed7d420e



## 如何使用

环境准备可参考

https://medium.com/geekculture/monitoring-websites-using-grafana-and-prometheus-69ccf936310c

注意：忽略blackbox setup步骤

- 安装Prometheus 

- 配置prometheus.yml

```
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]
  - job_name: "hey"
    scrape_interval: 1s
    static_configs:
      - targets: ['localhost:1010'] 
```

注意端口1010是写死的，后续计划修改成可以通过命令行进行随机赋值



- 安装Grafana 
- 引用数据，具体数据项如下

```ini
# HELP hey_average_latency hey average lantency of all requests
# TYPE hey_average_latency gauge
hey_average_latency 0.333023128238458
# HELP hey_avg_conn hey average lantency of connection setup(DNS lookup + Dial up)
# TYPE hey_avg_conn gauge
hey_avg_conn 0.0008299568803227264
# HELP hey_avg_delay hey average lantency between response and request
# TYPE hey_avg_delay gauge
hey_avg_delay 0.3276944901389514
# HELP hey_avg_dns hey average lantency of dns lookup
# TYPE hey_avg_dns gauge
hey_avg_dns 0
# HELP hey_avg_req hey average lantency of request "write"
# TYPE hey_avg_req gauge
hey_avg_req 9.923097265800088e-05
# HELP hey_avg_res hey average lantency of response "read"
# TYPE hey_avg_res gauge
hey_avg_res 0.004199986732406999
# HELP hey_fastest hey minimum lantency of all requests
# TYPE hey_fastest gauge
hey_fastest 0.0153465
# HELP hey_fastest_conn hey minimum lantency of connection setup(DNS lookup + Dial up)
# TYPE hey_fastest_conn gauge
hey_fastest_conn 0.0002317
# HELP hey_fastest_delay hey minimum lantency between response and request
# TYPE hey_fastest_delay gauge
hey_fastest_delay 0.007162
# HELP hey_fastest_dns hey minimum lantency of dns lookup
# TYPE hey_fastest_dns gauge
hey_fastest_dns 0
# HELP hey_fastest_req hey minimum lantency of request "write"
# TYPE hey_fastest_req gauge
hey_fastest_req 1.84e-05
# HELP hey_fastest_res hey minimum lantency of response "read"
# TYPE hey_fastest_res gauge
hey_fastest_res 7.03e-05
# HELP hey_num_res hey num of all requests
# TYPE hey_num_res gauge
hey_num_res 2231
# HELP hey_rps hey request of per second
# TYPE hey_rps gauge
hey_rps 148.46734517640908
# HELP hey_slowest_conn hey maximum lantency of connection setup(DNS lookup + Dial up)
# TYPE hey_slowest_conn gauge
hey_slowest_conn 0.0764439
# HELP hey_slowest_delay hey maximum lantency between response and request
# TYPE hey_slowest_delay gauge
hey_slowest_delay 0.6143227
# HELP hey_slowest_dns hey maximum lantency of dns lookup
# TYPE hey_slowest_dns gauge
hey_slowest_dns 0
# HELP hey_slowest_req hey maximum lantency of request "write"
# TYPE hey_slowest_req gauge
hey_slowest_req 0.0123371
# HELP hey_slowest_res hey maximum lantency of response "read"
# TYPE hey_slowest_res gauge
hey_slowest_res 0.1017448
# HELP hey_slowtest hey maximum lantency of all requests
# TYPE hey_slowtest gauge
hey_slowtest 0.6210238
```

## the end

最终效果如下~

选取几个进行展示

![](https://cdn.learnku.com/uploads/images/202201/20/89916/BCfdcsqBZZ.png!large)
注意：只有hey压测起来后，才可以采集到相关数据



最后感谢rakyll~



项目地址：https://github.com/zgxme/hey

下载地址：https://github.com/zgxme/hey/releases



如果对你有帮助的话，辛苦给个star鸭~

如有问题可以提issue，也可以在评论区互相交流。