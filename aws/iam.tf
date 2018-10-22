# These are predfined Amazon Policy ARNS

data "aws_iam_policy" "administrator" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "developers" {
  arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}

data "aws_iam_policy" "change_password" {
 arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

# AWS IAM GROUPS

# The "Admin" group is not managed by Terraform
data "aws_iam_group" "admins" {
  group_name = "Admins"
}

resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group_policy_attachment" "developers_policy" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "${data.aws_iam_policy.developers.arn}"
}

resource "aws_iam_group_policy_attachment" "change_password_policy" {
  group      = "${aws_iam_group.developers.name}"
  policy_arn = "${data.aws_iam_policy.change_password.arn}"
}

# AWS Policies

resource "aws_iam_policy" "vmimport" {
  description = "Role policy for VMIE Amazon Service."
  name        = "vmimport"
  policy      = <<POLICY
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket"
         ],
         "Resource":[
            "${aws_s3_bucket.city_amis.arn}",
            "${aws_s3_bucket.city_amis.arn}/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource":"*"
      }
   ]
}
POLICY
}

resource "aws_iam_policy" "city_host" {
  description = "Role policy for City Hosts"
  name = "CityHostPolicy"
  policy = <<POLICY
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "ec2:DescribeInstances"
         ],
         "Resource": "*"
      }
   ]
}
POLICY
}

resource "aws_iam_policy" "datadog" {
  description = "Access policy for Datadog 3rd Party account access."
  name        = "DatadogAWSIntegrationPolicy"
  path        = "/"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:Describe*",
        "budgets:ViewBudget",
        "cloudfront:GetDistributionConfig",
        "cloudfront:ListDistributions",
        "cloudtrail:DescribeTrails",
        "cloudtrail:GetTrailStatus",
        "cloudwatch:Describe*",
        "cloudwatch:Get*",
        "cloudwatch:List*",
        "codedeploy:List*",
        "codedeploy:BatchGet*",
        "directconnect:Describe*",
        "dynamodb:List*",
        "dynamodb:Describe*",
        "ec2:Describe*",
        "ecs:Describe*",
        "ecs:List*",
        "elasticache:Describe*",
        "elasticache:List*",
        "elasticfilesystem:DescribeFileSystems",
        "elasticfilesystem:DescribeTags",
        "elasticloadbalancing:Describe*",
        "elasticmapreduce:List*",
        "elasticmapreduce:Describe*",
        "es:ListTags",
        "es:ListDomainNames",
        "es:DescribeElasticsearchDomains",
        "health:DescribeEvents",
        "health:DescribeEventDetails",
        "health:DescribeAffectedEntities",
        "kinesis:List*",
        "kinesis:Describe*",
        "lambda:AddPermission",
        "lambda:GetPolicy",
        "lambda:List*",
        "lambda:RemovePermission",
        "logs:Get*",
        "logs:Describe*",
        "logs:FilterLogEvents",
        "logs:TestMetricFilter",
        "logs:PutSubscriptionFilter",
        "logs:DeleteSubscriptionFilter",
        "logs:DescribeSubscriptionFilters",
        "rds:Describe*",
        "rds:List*",
        "redshift:DescribeClusters",
        "redshift:DescribeLoggingStatus",
        "route53:List*",
        "s3:GetBucketLogging",
        "s3:GetBucketLocation",
        "s3:GetBucketNotification",
        "s3:GetBucketTagging",
        "s3:ListAllMyBuckets",
        "s3:PutBucketNotification",
        "ses:Get*",
        "sns:List*",
        "sns:Publish",
        "sqs:ListQueues",
        "support:*",
        "tag:GetResources",
        "tag:GetTagKeys",
        "tag:GetTagValues"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

# AWS ROLE

resource "aws_iam_role" "datadog" {
  name                  = "DatadogAWSIntegrationRole"
  assume_role_policy    = <<ASSUME
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::464622532012:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "7c3ffe5d059646d5962f7301cae37c7a"
        }
      }
    }
  ]
}
ASSUME
  description           = "3rd Party role for Datadog External Integration"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
}

resource "aws_iam_role_policy_attachment" "datadog_policy_attach" {
  role       = "${aws_iam_role.datadog.name}"
  policy_arn = "${aws_iam_policy.datadog.arn}"
}

resource "aws_iam_role" "vmimport" {
  name                  = "vmimport"
  description           = "3rd Party role for Amazon AMI via OVF Creator"
  assume_role_policy    = <<ASSUME
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "vmie.amazonaws.com" },
         "Action": "sts:AssumeRole",
         "Condition": {
            "StringEquals":{
               "sts:Externalid": "vmimport"
            }
         }
      }
   ]
}
ASSUME
}

resource "aws_iam_role_policy_attachment" "vmimport_policy_attach" {
  role       = "${aws_iam_role.vmimport.name}"
  policy_arn = "${aws_iam_policy.vmimport.arn}"
  }


resource "aws_iam_role" "city_host" {
  name               = "city_host"
  description        = "IAM Role for City Host machines"
  assume_role_policy = <<ASSUME
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "ec2.amazonaws.com" },
         "Action": "sts:AssumeRole"
      }
   ]
}
ASSUME
}

resource "aws_iam_instance_profile" "city_host_profile" {
  name = "city_host_profile"
  role = "${aws_iam_role.city_host.name}"
}


resource "aws_iam_role_policy_attachment" "city_host_policy_attach" {
  role = "${aws_iam_role.city_host.name}"
  policy_arn = "${aws_iam_policy.city_host.arn}"
}

