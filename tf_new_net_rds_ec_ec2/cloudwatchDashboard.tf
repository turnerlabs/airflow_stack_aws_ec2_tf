resource "aws_cloudwatch_dashboard" "cw_dashboard_airflow" {
  dashboard_name = "airflow_prod"

dashboard_body = <<EOF
{
  "widgets": [
    {
      "type":"metric",
      "x":0,
      "y":0,
      "width":6,
      "height":6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "TargetResponseTime",
            "LoadBalancer",
            "${aws_lb.airflow_lb.arn_suffix}"
          ]
        ],
        "period":300,
        "stat":"Average",
        "region":"${var.region}",
        "title":"ALB Response Time"
      }
    },
    {
      "type":"metric",
      "x":6,
      "y":0,
      "width":6,
      "height":6,
      "properties": {
        "metrics": [
          [
            "AWS/EC2",
            "CPUUtilization",
            "AutoScalingGroupName",
            "${aws_autoscaling_group.asg_worker_airflow.name}"
          ]
        ],
        "period":300,
        "stat":"Average",
        "region":"${var.region}",
        "title":"ASG CPU Usage"
      }
    },
    {
      "type":"metric",  
      "x":18,
      "y":0,
      "width":6,
      "height":6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "DatabaseConnections",
            "DBInstanceIdentifier",
            "${aws_db_instance.airflow_rds.id}"
          ]
        ],
        "period":300,
        "stat":"Average",
        "region":"${var.region}",
        "title":"RDS Database Connections"
      }
    },
    {
      "type":"metric",
      "x":0,
      "y":6,
      "width":6,
      "height":6,
      "properties": {
        "metrics": [
          [
            "AWS/ApplicationELB",
            "RequestCount",
            "LoadBalancer",
            "${aws_lb.airflow_lb.arn_suffix}"
          ]
        ],
        "period":300,
        "stat":"Average",
        "region":"${var.region}",
        "title":"ALB Request Count"
      }
    },
    {
      "type":"metric",  
      "x":6,
      "y":6,
      "width":6,
      "height":6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "CPUUtilization",
            "DBInstanceIdentifier",
            "${aws_db_instance.airflow_rds.id}"
          ]
        ],
        "period":300,
        "stat":"Average",
        "region":"${var.region}",
        "title":"RDS CPU Usage"
      }
    },
    {
      "type":"metric",
      "x":12,
      "y":6,
      "width":6,
      "height":6,
      "properties": {
        "metrics": [
          [
            "AWS/RDS",
            "NetworkTransmitThroughput",
            "DBInstanceIdentifier",
            "${aws_db_instance.airflow_rds.id}"
          ]
        ],
        "period":300,
        "stat":"Average",
        "region":"${var.region}",
        "title":"RDS Network Throughput"
      }
    }
  ]
}
EOF
}
