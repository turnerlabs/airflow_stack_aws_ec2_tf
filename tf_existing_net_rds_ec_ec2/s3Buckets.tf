# S3 Airflow Bucket
resource "aws_s3_bucket" "s3_airflow_bucket" {
  bucket        = "${var.prefix}-${var.s3_airflow_bucket_name}"
  force_destroy = "true"
  
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.airflow_s3_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }
}


# S3 Airflow log Bucket
resource "aws_s3_bucket" "s3_airflow_log_bucket" {
  bucket        = "${var.prefix}-${var.s3_airflow_log_bucket_name}"
  force_destroy = "true"

  lifecycle_rule {
    id      = "airflow_task_log"
    enabled = true

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.airflow_s3_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }
}

# S3 ALB access log Bucket
resource "aws_s3_bucket" "s3_airflow_access_log_bucket" {
  bucket        = "${var.prefix}-${var.s3_airflow_access_log_bucket_name}"
  force_destroy = "true"

  lifecycle_rule {
    id      = "airflow_access_logs"
    enabled = true
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.airflow_s3_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = {
    application     = var.tag_application
    contact-email   = var.tag_contact_email
    customer        = var.tag_customer
    team            = var.tag_team
    environment     = var.tag_environment
  }

policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.prefix}-${var.s3_airflow_access_log_bucket_name}/*",
      "Principal": {
        "AWS": [
          "${var.alb_accesslog_account}"
        ]
      }
    }
  ]
}
EOF
}

