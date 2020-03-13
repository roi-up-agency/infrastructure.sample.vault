[Tutorial of how to set Vault on GKE](https://codelabs.developers.google.com/codelabs/vault-on-gke/index.html?index=..%2F..cloud#0)

> Current files should be reorganized.


### Requirements


##### Enable APIs in your project.

* [Enable KMS API.](https://console.developers.google.com/apis/api/cloudkms.googleapis.com/overview?project=618507676650
)

* [Enable Resource Manager](https://console.developers.google.com/apis/library/cloudresourcemanager.googleapis.com?project=daas-internal-security)



##### Terraform service account

Add a service account in the project with the roles: 

* Editor
* Project IAM Admin

Generate the service account key in json format and copy it to **terraform/key.json**


### Installation

    # prep scripts
    $ sh scripts/enable-gcloud-apis.sh 
    
    $ sh scripts/install-vault-cli.sh 
    
    # deploy infrastructure
    $ cd terraform/
    $ terraform init
    $ terraform plan
    $ terraform apply
    
    
    # generate certificates.
    $ sh scripts/vault-certificates.sh