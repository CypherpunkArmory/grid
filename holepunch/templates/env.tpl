{{with secret "secret/holepunch"}}
DATABASE_URL={{.Data.DATABASE_URL}}
JWT_SECRET_KEY={{.Data.JWT_SECRET_KEY}}
MAIL_PASSWORD={{.Data.MAIL_PASSWORD}}
MAIL_USERNAME={{.Data.MAIL_USERNAME}}
ROLLBAR_TOKEN={{.Data.ROLLBAR_TOKEN}}
ROLLBAR_ENV={{.Data.ROLLBAR_ENV}}
RQ_REDIS_URL={{.Data.RQ_REDIS_URL}}
RQ_DASHBOARD_REDIS_URL={{.Data.RQ_REDIS_URL}}
MIN_CALVER={{.Data.MIN_CALVER}}
BASE_SERVICE_URL=${base_domain}
CONFIRM_URL=https://${base_domain}/account/confirm/{0}
STRIPE_KEY={{.Data.STRIPE_KEY}}
STRIPE_ENDPOINT={{.Data.STRIPE_ENDPOINT}}
{{end}}
