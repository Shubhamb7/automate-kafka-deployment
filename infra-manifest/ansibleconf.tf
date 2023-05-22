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
 
[connect]
%{ for ip in aws_instance.ec2connect.*.private_ip ~}
${ip}
%{ endfor ~}
 
[schemareg]
%{ for ip in aws_instance.ec2schemareg.*.private_ip ~}
${ip}
%{ endfor ~}
 
  EOT
  filename = "./ansible/hosts"
}
 
