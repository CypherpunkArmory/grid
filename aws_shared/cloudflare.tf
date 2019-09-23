resource "cloudflare_zone" "holepunch_stg_zone" {
  count = 1
  zone  = "testpunch.io"
  type  = "full"
}

