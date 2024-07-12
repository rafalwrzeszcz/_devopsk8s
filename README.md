# DevOps Test Requirements

This README.md provides an explanation of the requirements for a simple DevOps test, including Dockerizing the application, deploying with Kubernetes, setting up Prometheus monitoring, and integrating with the ELK stack.

## 1. Dockerize the Application

### Dockerfile
> Create a Dockerfile for the Python application. This file should include instructions to install all necessary dependencies, expose the correct port, and incorporate configurations managed by an appropriate .env file.

To build application Docker image run:

```shell
docker build .
```

By default `python:3.12.4-slim-bookworm` image is used as base environment. You can change version by setting
`BASE_IMAGE_VERSION=<python-image-version>` or override image entirely with `BASE_IMAGE=<base-image>` build argument:

```shell
docker build --build-arg BASE_IMAGE_VERSION=3.13-rc-slim .
```

(Flask handles loading .env with dotenv, nothing to do here.)

### Build and Test Locally
> Use Docker commands to build an image from the Dockerfile and run a container locally. Ensure the application functions correctly within the container.

To run locally use `docker compose up`. You can verify the app is working correctly with
`curl http://localhost:5000/ping`.

## 2. Deploy with Kubernetes

To deploy EKS cluster run:

```shell
./run-me.sh
```

To access MongoDB run:

```shell
kubectl port-forward -n default svc/mongodb 27017
```

### Kubernetes Deployment YAML File
Write a YAML file to describe how Kubernetes should deploy the Docker container. Include specifications such as the container image, resource requirements, number of replicas, and other configurations.

### LoadBalancer Service
Configure a LoadBalancer service in Kubernetes to enable external access to the application.

### Horizontal Pod Autoscaler (HPA)
> Include a configuration for Horizontal Pod Autoscaler (HPA) to automatically scale the application based on CPU usage.

Part of `run-me.sh` script.

## 3. Setup Prometheus Monitoring

### Prometheus Configuration
Configure Prometheus to monitor the application by specifying which metrics to scrape. This may include system metrics or custom application metrics.

### Deploy Prometheus within Kubernetes Cluster
> Deploy Prometheus as a container within the Kubernetes cluster to enable scraping metrics from the application.

Part of `run-me.sh` script.

To access Prometheus:

```shell
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090
```

### Visualize Metrics
> Visualize the Prometheus metrics through a simple dashboard

Part of `run-me.sh` script.

To access Grafana:

```shell
kubectl get secret -n monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
kubectl port-forward -n monitoring svc/grafana 80
```

## 4. Integrate with ELK Stack

### Filebeat Configuration
Configure Filebeat to watch the application's log files and ship them to Elasticsearch.

### Elasticsearch
> Ensure Elasticsearch is running within the environment to store and index the logs sent from Filebeat.

Part of `run-me.sh` script.

To access ElasticSearch:

```shell
kubectl get secret -n monitoring elasticsearch-master-credentials -o jsonpath="{.data.password}" | base64 --decode ; echo
kubectl port-forward -n monitoring svc/elasticsearch-master 9200
```

### Kibana
> Set up Kibana to visualize the logs stored in Elasticsearch. Create a dashboard in Kibana to display key information from the application's logs.

Part of `run-me.sh` script.

To access Kibana:

```shell
kubectl get secret -n monitoring kibana-kibana-es-token -o jsonpath="{.data.token}" | base64 --decode ; echo
kubectl port-forward -n monitoring svc/kibana-kibana 5601
```

## Evaluation Criteria

- Code quality, structure and organization
- Docker & Kubernetes best practices
- Application metrics, collect and visualize
- Logs Managment, collect and visualize logs

## Submission

Please create a public GitHub repository and send the link to your repository once you have completed the project to <development@united-remote.com>.
