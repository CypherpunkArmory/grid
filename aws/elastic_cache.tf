resource "aws_elasticache_cluster" "holepunch-redis" {
  cluster_id = "holepunch-${terraform.workspace}"
  engine = "redis"
  node_type = "cache.t2.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.redis4.0"
  engine_version = "4.0.10"
  subnet_group_name = "city-default"
  port = 6379

  tags {
    District = "city"
    Usage = "app"
    Name = "city_redis"
    Role = "db"
    Environment = "${terraform.workspace}"
  }
}
