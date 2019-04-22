resource "aws_elasticache_cluster" "holepunch-redis" {
  cluster_id = "holepunch-${terraform.workspace}"
  engine = "redis"
  node_type = "cache.t2.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.redis4.0"
  engine_version = "4.0.10"
  subnet_group_name = "${aws_elasticache_subnet_group.holepunch-redis-subnet-group.name}"
  apply_immediately = true
  port = 6379

  tags {
    District = "city"
    Usage = "app"
    Name = "city_redis"
    Role = "db"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_elasticache_subnet_group" "holepunch-redis-subnet-group" {
  name = "elasticache-subnet-group-${terraform.workspace}"
  subnet_ids = ["${aws_subnet.city_private_subnet.id}"]
}
