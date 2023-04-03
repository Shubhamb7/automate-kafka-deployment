resource "local_file" "ansible_hosts" {
  content  = <<EOT
[kafka]
%{ for i,ip in aws_instance.ec2broker.*.private_ip ~}
${ip} id=${i}
%{ endfor ~}
 
[zoo]
%{ for i,ip in aws_instance.ec2zoo.*.private_ip ~}
${ip} id=${i+1}
%{ endfor ~}
 
[provectus]
%{ for ip in aws_instance.ec2provectus.*.private_ip ~}
${ip}
%{ endfor ~}
 
  EOT
  filename = "./ansible/hosts"
}
 
