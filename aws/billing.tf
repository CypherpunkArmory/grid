resource "aws_budgets_budget" "cost" {
  name              = "budget-holepunch-beta"
  budget_type       = "COST"
  limit_amount      = "500"
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2019-02-01_00:00"
  time_unit         = "MONTHLY"
}
