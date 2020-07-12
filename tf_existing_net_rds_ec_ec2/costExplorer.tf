resource "aws_budgets_budget" "airflow_budget" {
  name              = "${var.prefix}-budget-airflow-monthly"
  budget_type       = "COST"
  limit_amount      = "300.0"
  limit_unit        = "USD"
  time_period_start = "2019-12-01_00:00"
  time_unit         = "MONTHLY"

  cost_filters = {
    TagKeyValue = "user:application$airflow"
  }

  cost_types {
    use_amortized = true
  }
}