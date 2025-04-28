# Docker Swarm Deployment with Jenkins

This project demonstrates a Docker Swarm deployment setup for a React application. The deployment is automated using Jenkins pipelines.

## Prerequisites

- Docker installed and configured
- Docker Swarm initialized
- Jenkins installed with the following plugins:
  - Docker Pipeline
  - Docker
  - SSH Agent
  - Credentials Binding

## Jenkins Pipeline Setup

1. Create a new freetyle project in Jenkins

2. Configure the following credentials in Jenkins:

   - Docker Hub credentials (Username with password access token)

Use the following script

```
echo %DOCKER_PASSWORD% | docker login -u %DOCKER_USERNAME% --password-stdin
call push-and-run.bat
```