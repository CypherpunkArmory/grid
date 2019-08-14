job "userland-hook" {
  datacenters = ["city"]
  vault {
    policies = ["userland-policy"]

    change_mode   = "restart"
  }

  type = "batch"

  group "script" {
    count = 1

    restart {
      attempts = 0
    }

    task "script" {
      driver = "docker"

      config = {
        image = "cypherpunkarmory/userland-production:${deploy_version}"
        force_pull = true
        entrypoint = ["/usr/local/bin/python", "-m"]
        command = "${hook}"
        args = ${args}
        labels {
          usage = "deploy-hook"
        }
      }

      env {
        "FLASK_ENV" = "production"
      }

      template {
        data = <<EOH
${env_template}
EOH
        destination = "/secrets/production"
        env         = true
        change_mode = "restart"
      }
    }
  }
}
