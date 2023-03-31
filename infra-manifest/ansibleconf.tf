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
 
[connect]
%{ for ip in aws_instance.ec2connect.*.private_ip ~}
${ip}
%{ endfor ~}
 
[schemareg]
%{ for ip in aws_instance.ec2schemareg.*.private_ip ~}
${ip}
%{ endfor ~}
 
[provectus]
%{ for ip in aws_instance.ec2provectus.*.private_ip ~}
${ip}
%{ endfor ~}
 
[prometheus]
%{ for ip in aws_instance.ec2prometheus.*.private_ip ~}
${ip}
%{ endfor ~}
 
[grafana]
%{ for ip in aws_instance.ec2grafana.*.private_ip ~}
${ip}
%{ endfor ~}
 
  EOT
  filename = "./ansible/hosts"
}
 
