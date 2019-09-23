##########  Get predefined Polices

data "aws_iam_policy" "administrator" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "developers" {
  arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}

data "aws_iam_policy" "change_password" {
  arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

data "aws_iam_policy" "dynamo_db" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

##### Get#### current account id
data "aws_caller_identity" "current" {
}

########## AWS IAM GROUPS

# The "Admin" group is not managed by Terraform
resource "aws_iam_group" "admins" {
  name = "Admins"
}

resource "aws_iam_group" "developers" {
  name = "Developers"
}

resource "aws_iam_group_policy_attachment" "developers_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = data.aws_iam_policy.developers.arn
}

resource "aws_iam_group_policy_attachment" "developers_admin_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = data.aws_iam_policy.administrator.arn
}

resource "aws_iam_group_policy_attachment" "change_password_policy" {
  group      = aws_iam_group.developers.name
  policy_arn = data.aws_iam_policy.change_password.arn
}

resource "aws_iam_group_policy_attachment" "dynamo_db_access" {
  group      = aws_iam_group.developers.name
  policy_arn = data.aws_iam_policy.dynamo_db.arn
}

resource "aws_iam_group" "robots" {
  name = "Robots"
}

######## AWS Service Users

# Email
resource "aws_iam_user" "emailer" {
  name = "emailer"
  tags = {
    Substrate = "silicon"
  }
}

resource "aws_iam_user_group_membership" "emailer_user_groups" {
  user = aws_iam_user.emailer.name
  groups = [
    aws_iam_group.robots.name,
  ]
}

resource "aws_iam_access_key" "emailer_key" {
  user = aws_iam_user.emailer.name
}

resource "aws_iam_policy" "emailer" {
  description = "Permission Policy for sending email via SES"
  name        = "emailer"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ses:SendRawEmail",
      "Resource": "*"
    }
  ]
}
POLICY

}

resource "aws_iam_user_policy_attachment" "emailer_emailer_policy_attach" {
  user       = aws_iam_user.emailer.name
  policy_arn = aws_iam_policy.emailer.arn
}

# Cert Bot

resource "aws_iam_user" "certbot" {
  name = "certbot"
  tags = {
    Substrate = "silicon"
  }
}

resource "aws_iam_user_group_membership" "certbot_user_groups" {
  user = aws_iam_user.certbot.name
  groups = [
    aws_iam_group.robots.name,
  ]
}

# The Robot Deploy User - Good for CI/CD

resource "aws_iam_user" "domoroboto" {
  name = "domoroboto"
  tags = {
    Substrate = "silicon"
  }
}

resource "aws_iam_user_group_membership" "domoroboto_user_groups" {
  user = aws_iam_user.domoroboto.name
  groups = [
    aws_iam_group.robots.name,
  ]
}

resource "aws_iam_access_key" "domoroboto_key" {
  user = aws_iam_user.domoroboto.name
}

resource "aws_iam_policy" "domoroboto" {
  description = "Permission policy for the deploy robot"
  name        = "domoroboto"
  policy      = <<POLICY
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CopyImage",
          "ec2:CreateImage",
          "ec2:CreateKeypair",
          "ec2:CreateSecurityGroup",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteKeyPair",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteSnapshot",
          "ec2:DeleteVolume",
          "ec2:DeregisterImage",
          "ec2:DescribeImageAttribute",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeRegions",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSnapshots",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DetachVolume",
          "ec2:GetPasswordData",
          "ec2:ModifyImageAttribute",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifySnapshotAttribute",
          "ec2:RegisterImage",
          "ec2:RunInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances"
         ],
         "Resource": "*"
      }
   ]
}
POLICY

}

resource "aws_iam_user_policy_attachment" "roboto_policy_attach" {
  user       = aws_iam_user.domoroboto.name
  policy_arn = aws_iam_policy.domoroboto.arn
}

###### Shared City Policy

resource "aws_iam_policy" "city_host" {
  description = "Role policy for City Hosts"
  name        = "CityHostPolicy"
  policy      = <<POLICY
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "ec2:DescribeInstances",
            "ec2:ModifyInstanceAttribute",
            "iam:GetInstanceProfile",
            "iam:GetUser",
            "iam:GetRole",
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:DescribeKey",
            "dynamodb:*"
         ],
         "Resource": "*"
      }
   ]
}
POLICY

}

###### City Hosts

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

# Attach global city policy
resource "aws_iam_role_policy_attachment" "city_host_policy_attach" {
  role       = aws_iam_role.city_host.name
  policy_arn = aws_iam_policy.city_host.arn
}

resource "aws_iam_instance_profile" "city_host_profile" {
  name = "city_host_profile"
  role = aws_iam_role.city_host.name
}

####### Load Balancer Hosts

resource "aws_iam_role" "lb_host" {
  name               = "lb_host"
  description        = "IAM Role for LB Host machines"
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

# Attach global city policy
resource "aws_iam_role_policy_attachment" "lb_city_host_policy_attach" {
  role       = aws_iam_role.lb_host.name
  policy_arn = aws_iam_policy.city_host.arn
}

resource "aws_iam_instance_profile" "lb_host_profile" {
  name = "lb_host_profile"
  role = aws_iam_role.lb_host.name
}

####### DMZ host

resource "aws_iam_role" "dmz_host" {
  name               = "dmz_host"
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

# Attach global city policy
resource "aws_iam_role_policy_attachment" "vault_dmz_role_policy_attach" {
  role       = aws_iam_role.dmz_host.name
  policy_arn = aws_iam_policy.city_host.arn
}

resource "aws_iam_instance_profile" "dmz_host_profile" {
  name = "dmz_host_profile"
  role = aws_iam_role.dmz_host.name
}

#Also attached city host to DMZ machine
resource "aws_iam_role_policy_attachment" "vault_city_host_policy_attach" {
  role       = aws_iam_role.dmz_host.name
  policy_arn = aws_iam_policy.city_host.arn
}

##########  Vault on DMZ host related

#     Used for allocating tokens for nodes to find the other nodes and for tokens
#     for automated services that need to manage AWS.  Certbot etc.
resource "aws_iam_policy" "vault_policy" {
  description = "Role policy for Vault AWS Secret Issuer"
  name        = "vault"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "vault-aws secret issuer policy",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vault-*"
      ]
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "dmz_vault_policy_attach" {
  role       = aws_iam_role.dmz_host.name
  policy_arn = aws_iam_policy.vault_policy.arn
}

######  Certbot container jobs to update route53

# THIS APPEARS TO BE DEAD CONFIG KILL ME  Though nothing calls it here
# It fails on the delte.  Perhaps using the same name was a mistake.
resource "aws_iam_policy" "certbot" {
  description = "Permission Policy for Certbot Auto"
  name        = "certbot"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "certbot-dns-route53 sample policy",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "route53:ListHostedZones",
              "route53:GetChange"
          ],
          "Resource": [
              "*"
          ]
      },
      {
          "Effect" : "Allow",
          "Action" : [
              "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
              "arn:aws:route53:::hostedzone/*"
          ]
      }
  ]
}
POLICY

}

resource "aws_iam_policy" "certbotpolicy" {
  description = "Permission Policy for Certbot Auto"
  name        = "certbot"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "certbot-dns-route53 sample policy",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "route53:ListHostedZones",
              "route53:GetChange"
          ],
          "Resource": [
              "*"
          ]
      },
      {
          "Effect" : "Allow",
          "Action" : [
              "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
              "arn:aws:route53:::hostedzone/*"
          ]
      }
  ]
}
POLICY

}

resource "aws_iam_role" "certbot" {
  name               = "certbot"
  description        = "IAM Role for certbot container"
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

resource "aws_iam_role_policy_attachment" "certbot_policy_attach" {
  role       = aws_iam_role.certbot.name
  policy_arn = aws_iam_policy.certbotpolicy.arn
}

########### Data dog configuration

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
        "tag:GetTagValues",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "xray:BatchGetTraces",
        "xray:GetTraceSummaries"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY

}

resource "aws_iam_role" "datadog" {
  name               = "DatadogAWSIntegrationRole"
  assume_role_policy = <<ASSUME
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
  role       = aws_iam_role.datadog.name
  policy_arn = aws_iam_policy.datadog.arn
}

