output "nat_gw_eip" {
  value = aws_eip.nat_gw.public_ip
}