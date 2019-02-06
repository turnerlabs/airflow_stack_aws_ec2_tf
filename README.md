# What is this?

This is the terraform code to create the following airflow architecture.

![AWS](images/airflow.jpg)

**tf_s3_state** 

- directory contains the terraform code to create an s3 bucket to store the terraform state for the terraform code in the other directory.

**tf_new_net_rds_ec_ec2_110**

- directory contains the terraform code to create the complete AWS airflow stack.