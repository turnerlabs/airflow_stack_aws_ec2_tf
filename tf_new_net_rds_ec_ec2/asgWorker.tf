# Airflow Worker Instance Related Items

resource "aws_launch_configuration" "lc_worker_airflow" {
  name                        = "${var.prefix}_lc_worker_airflow"
  image_id                    = var.airflow_worker_ami
  instance_type               = var.airflow_worker_instance_class
  key_name                    = var.airflow_keypair_name
  security_groups             = [aws_security_group.airflow_instance.id]
  iam_instance_profile        = aws_iam_instance_profile.airflow_s3_instance_profile.id
  user_data_base64            = base64encode(templatefile("${path.cwd}/templates/worker-user-data.tpl", { s3_airflow_bucket_name = aws_s3_bucket.s3_airflow_bucket.id, role_name = aws_iam_role.airflow_instance.name, db_region = var.region, airflow_secret = aws_secretsmanager_secret.airflow_sm_secret.id }))

  root_block_device {
    volume_type                 = "gp2"
    volume_size                 = 80
    delete_on_termination       = true
  }
}

resource "aws_autoscaling_group" "asg_worker_airflow" {
  name                      = "${var.prefix}_asg_worker_airflow"
  vpc_zone_identifier       =  [aws_subnet.airflow_subnet_private_1c.id, aws_subnet.airflow_subnet_private_1d.id]
  launch_configuration      = aws_launch_configuration.lc_worker_airflow.id
  max_size                  = "5"
  min_size                  = "1"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  termination_policies      = ["OldestInstance", "OldestLaunchConfiguration"]

  tag {
    key                 = "Name"
    value               = "${var.prefix}_airflow_worker_server"
    propagate_at_launch = true
  }

  tag {
    key                 = "application"
    value               = var.tag_application
    propagate_at_launch = true
  }

  tag {
    key                 = "contact-email"
    value               = var.tag_contact_email
    propagate_at_launch = true
  }

  tag {
    key                 = "customer"
    value               = var.tag_customer
    propagate_at_launch = true
  }

  tag {
    key                 = "team"
    value               = var.tag_team
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = var.tag_environment
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "airflow_worker_scale_up_policy" {
  name                      = "${var.prefix}_airflow_worker_scale_up_policy"
  scaling_adjustment        = 1
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 120
  autoscaling_group_name    = aws_autoscaling_group.asg_worker_airflow.name
}

resource "aws_cloudwatch_metric_alarm" "airflow_worker_cw_add_alarm" {
  alarm_name          = "${var.prefix}_airflow_worker_cw_add_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg_worker_airflow.name}"
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.airflow_worker_scale_up_policy.arn]
}

resource "aws_autoscaling_policy" "airflow_worker_scale_down_policy" {
  name                      = "${var.prefix}_airflow_worker_scale_down_policy"
  scaling_adjustment        = -1
  adjustment_type           = "ChangeInCapacity"
  cooldown                  = 240
  autoscaling_group_name    = aws_autoscaling_group.asg_worker_airflow.name
}

resource "aws_cloudwatch_metric_alarm" "airflow_worker_cw_remove_alarm" {
  alarm_name          = "${var.prefix}_airflow_worker_cw_remove_alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_worker_airflow.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.airflow_worker_scale_down_policy.arn]
}