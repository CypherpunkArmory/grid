resource "aws_db_instance" "city_rds" {
  allocated_storage = 10
  identifier = "city-db-${terraform.workspace}"
  storage_type = "gp2"
  engine = "postgres"
  engine_version = "10.6"
  instance_class = "${ terraform.workspace == "prod" ? "db.t2.small" : "db.t2.micro" }"
  availability_zone = "us-west-2c"
  username = "postgres"
  password = "${var.rds_password}"
  db_subnet_group_name = "${aws_db_subnet_group.city_db.name}"
  multi_az = false
  skip_final_snapshot = true
  publicly_accessible = true

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
  subnet_ids = ["${aws_subnet.city_vpc_subnet.id}", "${aws_subnet.city_backup_subnet.id}"]

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
  availability_zone = "us-west-2a"

  tags {
    District = "city"
    Usage = "infra"
    Role = "db"
    Environment = "${terraform.workspace}"
  }
}
