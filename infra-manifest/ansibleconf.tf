resource "local_file" "ansible_hosts" {
  content  = <<EOT
[kafka]
%{ for ip in aws_instance.ec2broker.*.private_ip ~}
${ip}
%{ endfor ~}
 
[zoo]
%{ for ip in aws_instance.ec2zoo.*.private_ip ~}
${ip}
%{ endfor ~}
 
  EOT
  filename = "./ansible/hosts"
}
