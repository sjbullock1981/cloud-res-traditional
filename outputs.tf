#DNS name of LB
output "LB-DNS-NAME" {
  value = aws_lb.application-lb.dns_name
}

#Postgres instance endpoint name
output "RDS-INSTANCE-ENDPOINT" {
  value = aws_db_instance.cloudres.endpoint
}