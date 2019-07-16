output "holepunch_redis_endpoint" {
  value = "redis://${aws_elasticache_cluster.holepunch-redis.cache_nodes.0.address}"
}

output "database_endpoint" {
  value = "postgres:${var.rds_password}@${aws_db_instance.city_rds.address}:5432"
}

output "tcp_lb_endpoint" {
  value = "${aws_instance.city_tcplb.private_ip}"
}