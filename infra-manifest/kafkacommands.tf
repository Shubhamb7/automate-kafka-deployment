resource "local_file" "kafka_commands" {
  content  = <<EOT
Kafka commands

List topics:
/opt/kafka/bin/kafka-topics.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.private_ip)-1] ~},%{ endif ~} %{ endfor ~} --list

Create topic:
/opt/kafka/bin/kafka-topics.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.private_ip)-1] ~},%{ endif ~} %{ endfor ~} --create --topic test

Delete topic:
/opt/kafka/bin/kafka-topics.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.private_ip)-1] ~},%{ endif ~} %{ endfor ~} --topic test --delete

Console Producer:
/opt/kafka/bin/kafka-console-producer.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.private_ip)-1] ~},%{ endif ~} %{ endfor ~} --topic test

Console Consumer:
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.private_ip)-1] ~},%{ endif ~} %{ endfor ~} --topic test

Performance Test:
/opt/kafka/bin/kafka-producer-perf-test.sh --topic test --num-records 200000 --throughput -1 --producer-props bootstrap.servers=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.private_ip)-1] ~},%{ endif ~} %{ endfor ~} --record-size 8000 

kafka cluster public ips:
%{ for ip in aws_instance.ec2broker.*.public_ip ~}${ip}:9094%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.public_ip)-1] ~},%{ endif ~} %{ endfor ~}

  EOT
  filename = "commands.txt"
}