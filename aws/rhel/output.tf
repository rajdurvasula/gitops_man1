output "private_ip_addresses_lin" {
  value = data.aws_instance.private_ips_lin.*.private_ip
}

output "public_ip_addresses_win" {
  value = data.aws_instance.ips_win.*.public_ip
}

output "private_ip_addresses_win" {
  value = data.aws_instance.ips_win.*.private_ip
}

output "public_dns_win" {
  value = data.aws_instance.ips_win.*.public_dns
}

output "private_dns_win" {
  value = data.aws_instance.ips_win.*.private_dns
}
