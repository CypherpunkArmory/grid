resource "aws_s3_bucket" "city_amis" {
  bucket = "city-amis"
  region = "us-west-2"
  acl = "private"

  tags {
    Name = "Userland City AMIs"
    Environment = "production"
    District = "city"
    Usage = "infra"
  }
}
