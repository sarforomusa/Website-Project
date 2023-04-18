# Creating the Public IP of the Website Server
output "Website-Public-ip" {
  description = "Public IP address of the server"
  value       = aws_eip.Website-EIP[0].public_ip
  depends_on  = [aws_eip.Website-EIP]
}

# Creating Public DNS address for the server
output "Website_public_dns" {
  description = "Public DNS address for the server"
  value       = aws_eip.Website-EIP[0].public_dns
  depends_on  = [aws_eip.Website-EIP]

}

# Creating database endpoint
output "database_endpoint" {
  description = "database endpoint"
  value       = aws_db_instance.Web.address

}

# Creating database port

output "database_port" {
  description = "database port"
  value       = aws_db_instance.Web.port

}