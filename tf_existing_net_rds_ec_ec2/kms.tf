resource "aws_kms_key" "airflow_rds_kms_key" {
  description             = "Airflow RDS KMS Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = {
    Name            = "${var.prefix}-airflow-rds"
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account_number}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.aws_account_number}:root",
                    "${aws_iam_role.airflow_instance.arn}"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.aws_account_number}:root",
                    "${aws_iam_role.airflow_instance.arn}"
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}  
EOF
}

resource "aws_kms_key" "airflow_s3_kms_key" {
  description             = "Airflow S3 KMS Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = {
    Name            = "${var.prefix}-airflow-s3"
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "key-consolepolicy-3",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account_number}:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.aws_account_number}:root",
                    "${aws_iam_role.airflow_instance.arn}"
                ]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.aws_account_number}:root",
                    "${aws_iam_role.airflow_instance.arn}"
                ]
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
}  
EOF
}
