# this section stores the terraform state for the s3 bucket in the terraform state bucket we created in step 1.
terraform {
  required_version = ">=0.12.19"

  backend "s3" {
    bucket = "tf-state-cas-airflow" # the terraform state bucket has to be hand entered unfortunately
    key    = "tf_existing_net_rds_ec_ec2/terraform.tfstate"
    region = "us-east-1"
  }
}

# this is for an aws specific provider(not gcp or azure)
provider "aws" {
  version = "~> 2.44.0"
  region  = "us-east-1"
  profile = "aws-cloudarch-sandbox:aws-cloudarch-sandbox-admin"
}

provider "random" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}
