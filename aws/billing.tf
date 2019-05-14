resource "aws_budgets_budget" "cost" {
  name              = "budget-holepunch-${terraform.workspace}"
  budget_type       = "COST"
  limit_amount      = "${terraform.workspace == "prod" ? 500.0 : 100.0}"
  limit_unit        = "USD"
  time_period_start = "2019-02-01_00:00"
  time_period_end   = "2087-06-15_00:00"
  time_unit         = "MONTHLY"

  cost_filters = {
    TagKeyValue = "user:Environment$$${terraform.workspace}"
  }
}
