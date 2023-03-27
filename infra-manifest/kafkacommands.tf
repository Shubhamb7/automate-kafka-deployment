resource "local_file" "kafka_commands" {
  content  = <<EOT
Kafka commands

List topics:
/opt/kafka/bin/kafka-topics.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.public_ip)-1] ~},%{ endif ~} %{ endfor ~} --list

Create topic:
/opt/kafka/bin/kafka-topics.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.public_ip)-1] ~},%{ endif ~} %{ endfor ~} --create --topic  

Delete topic:
/opt/kafka/bin/kafka-topics.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.public_ip)-1] ~},%{ endif ~} %{ endfor ~} --topic <topic-name> --delete

Console Producer:
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.public_ip)-1] ~},%{ endif ~} %{ endfor ~} --topic

Console Consumer:
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.public_ip)-1] ~},%{ endif ~} %{ endfor ~} --topic

kafka cluster public ips:
%{ for ip in aws_instance.ec2broker.*.public_ip ~}${ip}:9094%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.public_ip)-1] ~},%{ endif ~} %{ endfor ~}

  EOT
  filename = "commands.txt"
}