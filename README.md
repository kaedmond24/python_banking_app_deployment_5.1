<p align="center">
<img src="">
</p>
<h1 align="center">Retail Banking App Deployment 5.1<h1>

# Purpose

This deployment follows up with [Retail Banking App Deployment](https://github.com/kaedmond24/python_banking_app_deployment_5) by redeploying the retail banking app into multiple application servers.

AWS cloud infrastructure is deployed using Terraform, setting up a Jenkins CI/CD server and two Web application servers running Gunicorn and Python code.

## Deployment Files:

The following files are needed to run this deployment:

- `app.py` The main python application file
- `database.py` Python file to create application database
- `load_data.py` Python file to load data into into the database
- `test_app.py` Test functions used to test application functionality
- `requirements.txt` Required packages for python application
- `main.tf` Terraform file to deploy AWS infrastructure
- `jenkins_server.sh` Bash script to install and run Jenkins
- `app_server.sh` Bash script to install required packages for the app server
- `Jenkinsfile` Configuration file used by Jenkins to run a pipeline
- `README.md` README documentation
- `static/` Folder housing CSS files
- `templates/` Folder housing HTML templates
- `images/` Folder housing deployment artifacts

# Steps

1. TBA

2. TBA

3. TBA

# System Diagram

CI/CD Pipeline Architecture [Link](https://github.com/kaedmond24/python_banking_app_deployment_5/blob/main/c4_deployment_5_1.png)

# Issues

TBA

# Optimization

1. TBA
