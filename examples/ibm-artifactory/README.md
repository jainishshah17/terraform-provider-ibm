# Terraform Template For Artifactory Enterprise on IBM Public Cloud

### Prerequisites:
* An IBM Public Cloud account
* Basic knowledge of IBM Public Cloud
* Predefined Keys (Bluemix API Key, SoftLayer API Key)
* Basic knowledge of Artifactory
* Database (MySQL/Postgres/MsSQL)
* Learn about [system requirements for Artifactory](https://www.jfrog.com/confluence/display/RTF/System+Requirements#SystemRequirements-RecommendedHardware)
* Learn more about Terraform IBM provider follow: https://github.com/IBM-Cloud/terraform-provider-ibm

### Steps to Deploy Artifactory Enterprise Using Terraform Template
1. Set your IBM account credentials by setting environment variables: 
   ```
       export BM_API_KEY="your_blumix_key"
       export SL_API_KEY="your_softlayer_key"
       export SL_USERNAME="your_softlayer_username"
   ```
   To learn more about Terraform ibm provider follow there documentation.
   https://github.com/IBM-Cloud/terraform-provider-ibm

2. Modify the default values in the `variables.tf` file  

   For example: Change disk space to 500Gb:
   ```
    variable "vm-disk-size" {
      description = "Disk size for each VM"
      default     = 500
    }
   ```
3. Run the `terraform init` command. This will install the required plugin for the ibm provider.

4. Run the `terraform plan` command.

5. Run the `terraform apply` command to deploy Artifactory Enterprise cluster on ibm cloud
   
    **Note**: it takes approximately 15 minutes to bring up the cluster.

6. You will receive LB URL to access Artifactory. By default, this template starts only one node in the Artifactory cluster. 
   It takes 7-10 minutes for Artifactory to start and to attach the instance to the LB.The output can be viewed as:
    ```
    Outputs:
    
    artifactory_url = http://198.23.117.180
    ```

7. Access the Artifactory UI using LB URL provided in outputs.

8. Scale your cluster using following command: `terraform apply -var 'auto-scale-minimum-member-count=2'`
   In this example we are scaling artifactory cluster to 2 nodes.
   
    **Note**: You can only scale nodes to number of artifactory licenses you have available for cluster.

9. SSH into Artifactory primary instance and type [inactiveServerCleaner](inactiveServerCleaner.groovy) plugin in `'/var/opt/jfrog/artifactory/etc/plugins'` directory.
    (Optional) To destroy the cluster, run  the following commend: `terraform destroy`

### Note:
* This template only supports Artifactory version 5.8.x and above.
* Turn off daily backups. Read Documentation provided [here](https://www.jfrog.com/confluence/display/RTF/Managing+Backups).
* Use an SSL Certificate with a valid wildcard to your artifactory as docker registry with subdomain method.

### Steps to setup Artifactory as secure docker registry
Considering you have SSL certificate for `*.jfrog.team`
1. Pass your SSL Certificate in variable `ssl_certificate` as string
2. Pass your SSL Certificate Key in variable `ssl_certificate_key` as string
3. Set `certificate_domain` as `jfrog.team`
4. Set `artifactory_server_name` as `artifactory` if you want to access artifactory with `https://artifactory.jfrog.team`
5. Create DNS for example Route53 with entry `artifactory.jfrog.team` pointing to LB value provided as output in Terraform Stack.
6. Create DNS for example Route53 with entry `*.jfrog.team pointing` to LB value provided as output in Terraform Stack.
7. If you have virtual docker registry with name `docker-virtual` in artifactory. You can access it via `docker-virtual.jfrog.team` e.g `docker pull docker-virtual.jfrog.team/nginx`

### Steps to upgrade Artifactory Version
1. Change the value of `artifactory_version` from old version to new Artifactory version you want to deploy. for e.g. `5.8.1` to `5.8.2`.

2. Run command `terraform apply -var 'secondary_node_count=2' -ver 'artifactory_version=5.8.2'`.
   You will see instances will get upgraded one by one. Depending on your cluster size it will take 20-30 minutes to update stack.

### Use Artifactory as backend
To to store state as an artifact in a given repository of Artifactory, see [https://www.terraform.io/docs/backends/types/artifactory.html](https://www.terraform.io/docs/backends/types/artifactory.html)
