output "broker_private_ips" {
  value = aws_instance.ec2broker.*.private_ip
}

output "broker_public_ips" {
  value = aws_instance.ec2broker.*.public_ip
}

output "zoo_private_ips" {
  value = aws_instance.ec2zoo.*.private_ip
}

output "zoo_public_ips" {
  value = aws_instance.ec2zoo.*.public_ip
}

output "connect_public_ips" {
  value = aws_instance.ec2connect.*.public_ip
}

output "connect_private_ips" {
  value = aws_instance.ec2connect.*.private_ip
}

output "mm_public_ips" {
  value = aws_instance.ec2mm.*.public_ip
}

output "mm_private_ips" {
  value = aws_instance.ec2mm.*.private_ip
}

output "schema_public_ips" {
  value = aws_instance.ec2schemareg.*.public_ip
}

output "schema_private_ips" {
  value = aws_instance.ec2schemareg.*.private_ip
}

output "cruise_private_ips" {
  value = aws_instance.ec2cruise.*.private_ip
}

output "cruise_public_ips" {
  value = aws_instance.ec2cruise.*.public_ip
}

output "provectus_private_ips" {
  value = aws_instance.ec2provectus.*.private_ip
}

output "provectus_public_ips" {
  value = aws_instance.ec2provectus.*.public_ip
}

output "prometheus_private_ips" {
  value = aws_instance.ec2prometheus.*.private_ip
}

output "prometheus_public_ips" {
  value = aws_instance.ec2prometheus.*.public_ip
}

output "ansible_public_ip" {
  value = aws_instance.ansible.public_ip
}

output "security_group_ids" {
  value = aws_security_group.sg.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
}