#!/bin/bash -xe

export AIRFLOW_HOME=/home/ec2-user/airflow

echo $'' >> /etc/environment
echo $'' >> /etc/profile.d/airflow.sh

echo "S3_AIRFLOW_BUCKET=${s3_airflow_bucket_name}" >> /etc/environment
echo "S3_AIRFLOW_BUCKET=${s3_airflow_bucket_name}" >> /etc/profile.d/airflow.sh

export S3_AIRFLOW_BUCKET=${s3_airflow_bucket_name}

secret=`/home/ec2-user/venv/bin/aws secretsmanager get-secret-value --region ${db_region} --secret-id ${airflow_secret}`
token=$(echo $secret | jq -r .SecretString)

echo "RDS_KEY=$token" >> /etc/environment
echo "RDS_KEY=$token" >> /etc/profile.d/airflow.sh

export RDS_KEY=$token

echo "############# Set initial environment variables for cron and systemd #############"

/home/ec2-user/venv/bin/aws s3 cp s3://${s3_airflow_bucket_name}/ /home/ec2-user/airflow/ --recursive --quiet

if [ ! -e "/home/ec2-user/airflow/airflow.cfg" ]; then
    sleep 5m
    
    /home/ec2-user/venv/bin/aws s3 cp s3://${s3_airflow_bucket_name}/ /home/ec2-user/airflow/ --recursive --quiet
fi

echo "############# Copy important files from s3 locally #############"

chown -R ec2-user:ec2-user /home/ec2-user/airflow

chmod 600 /home/ec2-user/airflow/airflow.cfg
chmod 600 /home/ec2-user/airflow/unittests.cfg
chmod 600 /home/ec2-user/airflow/webserver_config.py
chmod 700 /home/ec2-user/airflow/connect.sh
chmod 700 /home/ec2-user/airflow/sm_update.sh

echo "############# Apply owndership and execution priviliges #############"

mkdir -p ${efs_mount_point}
echo "${efs_dns_name}:/ ${efs_mount_point} efs" | sudo tee -a /etc/fstab
mount -a
chown ec2-user:ec2-user ${efs_mount_point}
cat /proc/mounts | grep airflow

echo "############# Mount EFS #############"

systemctl enable airflow-worker

systemctl daemon-reload

echo "############# Enabled airflow systemd #############"

systemctl start airflow-worker

echo "############# Started up airflow service #############"