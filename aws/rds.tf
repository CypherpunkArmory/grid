data "aws_db_snapshot" "latest_prod_snapshot" {
  most_recent = true
  db_instance_identifier = "city-db-prod"
}

locals {
  db_identifier = "city-db-${terraform.workspace}"
}

resource "aws_db_instance" "city_rds" {
  identifier = "${local.db_identifier}"
  storage_type = "gp2"
  engine_version = "10.6"
  instance_class = "${ terraform.workspace == "prod" ? "db.t3a.small" : "db.t2.micro" }"
  availability_zone = "us-west-2c"
  db_subnet_group_name = "${aws_db_subnet_group.city_db.name}"
  multi_az = false
  publicly_accessible = true
  backup_retention_period = "${terraform.workspace == "prod" ? 14 : 0}"
  skip_final_snapshot = "${ terraform.workspace == "prod" ? false : true }"
  final_snapshot_identifier = "${local.db_identifier}-final"
  copy_tags_to_snapshot = "${ terraform.workspace == "prod" ? true : false }"
  # change this to restor prod from latest
  snapshot_identifier = "${ terraform.workspace == "prod" ? "rds:city-db-prod-2019-05-15-00-25" : data.aws_db_snapshot.latest_prod_snapshot.id }"
   vpc_security_group_ids = [
     "${ aws_security_group.city_servers.id }",
   ]

  snapshot_identifier = "${ terraform.workspace == "prod" ? "rds:city-db-prod-2019-05-15-00-25" : data.aws_db_snapshot.latest_prod_snapshot.id }"
  vpc_security_group_ids = [
    "${ aws_security_group.city_servers.id }",
  ]

  tags {
    District = "city"
    Usage = "app"
    Name = "city_db"
    Role = "db"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_db_subnet_group" "city_db" {
  name = "db-${terraform.workspace}"
  subnet_ids = [
    "${aws_subnet.city_vpc_subnet.id}",
    "${aws_subnet.city_backup_subnet.id}",
    "${aws_subnet.city_private_subnet.id}"
  ]

  tags {
    District = "city"
    Usage = "db"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_subnet" "city_backup_subnet" {
  vpc_id = "${aws_vpc.city_vpc.id}"
  cidr_block = "172.31.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-west-2c"

  tags {
    District = "city"
    Usage = "infra"
    Role = "db"
    Environment = "${terraform.workspace}"
  }
}
