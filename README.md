# The Grid

Grid is our descriptive infrastructure repository.  We use Terraform to manage
the overall infrastructure of the UserLAnd, etc infrastructure.

Terraform is _basically_ a managed API caller - and takes data from one API (or
the same API at a different endpoint and uses it in calls to a different API.)

In order to accomplish this, Terraform maintains a consistent view of the
infrastructure in a file called "The State" - our Terraform organization
splits this file into several independently managed pieces based on their
change velocity.

1. Github
2. AWS Shared (IAM, Network, DNS, Etc)
3. AWS Environment
4. Users (Manages users for Terraform Compatible APIS)

In order to modify these files, you need to either CD into the respective
directory or use the `./tf` helper script.

`./tf aws <your terraform commands>`

A Terraform tutorial is outside the scope of this README, but here are some
tips for making changes.

## Making A Temporary Environment

In order to spin up test environments switch to the `aws` directory and then
use a terraform workspace to create a new instance of the environment.

The domains are preset to

1. DMZ - <yourenvname>.testinghole.com
2. API - <yourenvname>.orbtestenv.net


## Tagging Resources

Your resources should be tagged liberally.  You're going to want to find them
later.
