# The Grid


Grid is our descriptive infrastructure repository.  We use Terraform to manage
the infastructure for each of our projects from one repo.

We don't currently have a remote Terraform store, so you need to coordinate over
voice network (ie, yell over the wall) that you are making infra changes.

Currently we're keeping AWS and Github Repos in here - but that's just to start.

You can think of Terraform as basically being an API manager - it's a way to
link disparate APIs together using "common data" that we store in this repo.

Terraform Modules are organized in a couple of different dimensions.

"Global" configuration is under a the namespace of the provider - so the
definition of github repositories for this repo, the Userland Team, etc are
under `/github` AWS Policy documents etc, are under `/aws`

Project specific infrastructure is under the project directory - "Dumont" for
instance - the python API that handles authentication and spin up request are
under `/dumont`

Project specific infrastructure may use multiple providers (and might duplicate
data sources.)

## Limitations of Terraform

Terraform doesn't allow you to "reference" modules from other modules, so we
can't do something like reference the "Team" we created in Github in the User
Module, we have to pass it in explicity.

Maybe Terraform 0.12 solves this - it makes a lot of changes to HCL.
