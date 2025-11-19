# Personal Website

This repository contains my personal website project along with a complete CI/CD pipeline setup for automated testing, Docker image creation, and deployment to Kubernetes (Minikube).

## Project Overview

This project is a static and dynamic website built with HTML, CSS, and JavaScript. The goal of this repository is to demonstrate a **full DevOps workflow** including source control, code quality analysis, containerization, and deployment orchestration.

## Tools & Technologies Used

- **Version Control**: Git & GitHub
- **CI/CD**: Jenkins
- **Code Quality & Analysis**: SonarQube
- **Containerization**: Docker
- **Container Registry**: Docker Hub
- **Kubernetes Orchestration**: Minikube
- **Kubernetes Management Tools**: Kustomize, `kubectl`
- **Secrets & Credentials Management**: Jenkins Credentials Plugin
- **Shell Scripting**: Bash

## Repository Structure

├── k8s/ # Kubernetes manifests
│ ├── base/ # Base manifests for deployment, service, ingress
│ └── overlays/ # Dev and Prod overlays
│ ├── dev/ # Dev environment patches
│ └── prod/ # Prod environment patches
├── src/ # Website source code
│ ├── index.html
│ ├── styles.css
│ └── script.js
├── Jenkinsfile # CI/CD pipeline definition
└── README.md # This documentation


## CI/CD Pipeline

This project uses **Jenkins** to automate the following steps:

1. **Checkout Code**
   - Pulls the `main` branch from GitHub using stored credentials.  
   - Generates a short Git commit hash to use as the Docker image tag.

2. **SonarQube Analysis**
   - Performs static code analysis on HTML, CSS, and JavaScript files.  
   - Checks for code quality issues using a SonarQube server.

3. **Docker Build & Push**
   - Builds a Docker image of the website.  
   - Tags the image with the short commit hash.  
   - Pushes the image to Docker Hub using stored credentials.

4. **Update Kubernetes Manifests**
   - Automatically updates Kustomize overlays for dev and prod with the new Docker image tag.  
   - Commits changes back to GitHub (skipping CI to avoid loops).

5. **Kubernetes Resources Overview**
   - Lists deployments, services, and ingress resources in both dev and prod namespaces.  
   - Verifies that the website is deployed correctly in Minikube.

## Setup Instructions

### 1. Clone Repository
```bash
git clone https://github.com/ahmedsayedtalib/website.git
cd website

2. Jenkins Setup

Install Jenkins and the following plugins:

Git

Docker Pipeline

Kubernetes CLI

SonarQube Scanner

Create credentials in Jenkins:

GitHub token

SonarQube token

Docker Hub username/password

Kubernetes config token (for Minikube access)

3. Docker

Ensure Docker is installed and running.

Jenkins will build and push images automatically during the pipeline run.

4. Kubernetes (Minikube)

Ensure Minikube is installed and running.

Use Kustomize overlays for environment-specific deployment.

How to Run the Pipeline

Open Jenkins and create a new pipeline job.

Set the pipeline to read the Jenkinsfile from this repository.

Run the pipeline manually or configure webhook triggers on GitHub.

Monitor each stage (Checkout, SonarQube, Docker Build & Push, K8s Updates).

Check Kubernetes resources in dev and prod to verify deployment.

Notes

Docker image tags are automatically generated from Git commit hashes for traceability.

SonarQube analyzes only *.html, *.css, and *.js files.

Kustomize is used for managing environment-specific overrides for dev and prod.

The pipeline is fully automated with minimal manual intervention.

Contact

For questions or contributions, reach out to Ahmed Sayed Talib Osman at ahmedsayedtalib@outlook.com
