<p align="center">
<img src="">
</p>
<h1 align="center">Retail Banking App Deployment 5.1<h1>

# Purpose

This deployment follows up with [Retail Banking App Deployment](https://github.com/kaedmond24/python_banking_app_deployment_5) by redeploying the retail banking app into multiple application servers.

AWS cloud infrastructure is deployed using Terraform, setting up a Jenkins CI/CD server and two Web application servers running Gunicorn, Python, and SQLite code.

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

1. Development of the infrastructure using Terraform. The `main.tf` file houses the code to deploy the AWS infrastructure. The infrastructure includes a VPC, route table, two subnets (public) in two availability zones, two route table/subnet associations, security group, and three EC2 instances (jenkins server, app server 1, app server 2). Run this command the deploy the infrastructure:<br>

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

   <br><br>

2. Connect to app server 1 and configure the required packages. Login into the app server and run the following commands:

   ```bash
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt install -y python3.7 python3.7-venv

    #  Setup Datadog agent for monitoring
    DD_API_KEY=*******************************************
    DD_SITE="us5.datadoghq.com"
    DD_APM_INSTRUMENTATION_ENABLED=host
    bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"
   ```

   <br><br>

3. Connect to app server 2 and configure the required packages. Login into the app server and run the following commands:

   ```bash
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt install -y python3.7 python3.7-venv

    #  Setup Datadog agent for monitoring
    DD_API_KEY=*******************************************
    DD_SITE="us5.datadoghq.com"
    DD_APM_INSTRUMENTATION_ENABLED=host
    bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"
   ```

   <br><br>

4. The Jenkins server needs to be set up with some additional packages to meet python configuration requirements. First, verify that the Jenkins application is accessible at the public IP address returned after applying the terraform implementation.

   ```bash
   http://<jenkins-server-public-ip>:8080
   ```

   <br>

   Retrieve initial Jenkins password:

   ```bash
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

   <br>

   Connect to the Jenkins server and run the following commands:

   ```bash
   sudo apt install -y software-properties-common
   sudo add-apt-repository -y ppa:deadsnakes/ppa
   sudo apt install -y python3.7 python3.7-venv

   #  Setup Datadog agent for monitoring
   DD_API_KEY=*******************************************
   DD_SITE="us5.datadoghq.com"
   DD_APM_INSTRUMENTATION_ENABLED=host
   bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script_agent7.sh)"
   ```

   <br><br>

5. Setup Jenkins CI/CD pipeline in the Jenkins application at `http://<jenkins-server-public-ip>:8080`.

   - Login: username | password

   Install `Pipeline Keep Running Step` Jenkins plugin.

   - Navigate to `Managed Jenkins` > `Plugins` > `Available plugins`
   - Search: `Pipeline Utility Steps` > Check box > Install
   - Verify installation under `Installed plugins`.
     <br><br>

6. A Jenkins agent will be set up on app server 1. The agent’s configuration will allow Jenkins to establish an ssh connection with the server and run specified pipeline jobs on the remote host. Configure the agent in Jenkins by navigating to `Dashboard` > `Build Executor Status` > `New Node`.

   - Node name: `awsDeploy`
   - Select `Permanent Agent`
   - Number of executors: `1`
   - Remote root directory: `/home/ubuntu/agent1`
   - Labels: `awsDeploy`
   - Usage: `Only build jobs with label expressions matching this node`
   - Launch method: `Launch agents via SSH`
   - Host: `<APP_SERVER_1_PUBLIC_IP>`
   - Credentials: `ubuntu`
   - Host Key Verification Strategy: `Non verifying Verification Strategy`
   - Availability: `Keep this agent online as much as possible`
   - `SAVE`

   Agent will be available a few minutes after saving. <br><br>

7. In Jenkins, setup Jenkins CI/CD pipeline build.

   - From Dashboard, select a `new item` > `Create Name` > `Mulit-branch Pipeline` option
   - Set Branch sources:
     - Credentials: [How to setup Github Access Token](https://docs.github.com/en/enterprise-server@3.8/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
     - Repository HTTPS URL: `<Github Repo URL>`
     - Build Configuration > `Mode` > `Script Path`: `Jenkinsfile`
   - `Apply` and `Save`<br><br>

   Run the build.
   Check application status on app server 1 at `http://<app_server_1_public_ip>:8000`<br><br>

8. We need to set up an additional Jenkins agent on app server 2. Follow the same steps as with the app server 1 agent setup:

   - Node name: `awsDeploy2`
   - Select `Permanent Agent`
   - Number of executors: `1`
   - Remote root directory: `/home/ubuntu/agent1`
   - Labels: `awsDeploy`
   - Usage: `Only build jobs with label expressions matching this node`
   - Launch method: `Launch agents via SSH`
   - Host: `<APP_SERVER_2_PUBLIC_IP>`
   - Credentials: `ubuntu`
   - Host Key Verification Strategy: `Non verifying Verification Strategy`
   - Availability: `Keep this agent online as much as possible`
   - `SAVE`

   Agent will be available a few minutes after saving. <br><br>

9. In Github, update the Jenkinsfile to run the clean and deploy stages on both app servers via the agent. The following commands updates the Jenkinsfile using git locally:

   ```bash
   git branch jenkins_config
   git checkout jenkins_config

   # Add updated agent config to Jenkinsfile:

   # stage ('Clean') {
   # agent {label `'awsDeploy && awsDeploy2'`}
   # steps {

   # stage ('Deploy') {
   # agent {label 'awsDeploy && awsDeploy2'}
   # steps {

   git add Jenkinsfile
   git commit -m “commit message”
   git checkout main
   git merge jenkins_config
   git push -u origin main
   ```

   <br><br>

10. In Jenkins, run the pipeline build again to deploy the application on both app servers. If pipeline run completes successfully, the application will be available at:

    ```text
    App Server 1: http://<app_server_1_public_ip>:8000

    App Server 2: http://<app_server_2_public_ip>:8000
    ```

    <br><br>

# System Diagram

CI/CD Pipeline Architecture [Link](https://github.com/kaedmond24/python_banking_app_deployment_5.1/blob/main/c4_deployment_5_1.png)

# Issues

TBA

# Optimization

1. What should be added to the infrastructure to make the application more available to users?

- The infrastructure as constructed deploys the application successfully and allows users to interact fully with the banking application. However, two major flaws exist within the architecture. For starters, two separate instances of the application are running in the environment without any synchronization between them. Although both servers can communicate, their application logic is not configured to do so. In order to optimize the application’s functionality and user experience modifications would need to be made to the backend and frontend. On the backend, managed database service, such as AWS RDS, could be used to manage application data without having to manage underlying infrastructure. This change would also allow users to have a shared experience no matter which application server they are interacting with. For the frontend, a load balancer can be implemented to manage incoming requests for the application balancing the traffic between both application servers. Now, users can access the application using a single IPaddress (or DNS name) to access the application.


2. What is the purpose of a Jenkins agent?

- The Jenkins agent is used to manage pipeline jobs using remote hosts (nodes) to execute the job. An agent’s configuration offers a list of configuration details, including authentication. These configurations give Jenkins the necessary configuration and permissions to perform tasks on the select nodes. Ultimately, this allows Jenkins to run distributed builds improving the security posture of the CI/CD pipeline. Moreover, pipeline jobs can be run in parallel increasing deployment speed while allowing for additional benefits such as scalability and environment isolation.
