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

Producer Performance Test:
/opt/kafka/bin/kafka-producer-perf-test.sh --topic test --num-records 400000 --throughput -1 --producer-props bootstrap.servers=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.private_ip)-1] ~},%{ endif ~} %{ endfor ~} batch.size=16384 acks=1 linger.ms=1000 buffer.memory=33554432 request.timeout.ms=30000 delivery.timeout.ms=120000 --record-size 8000 

Consumer Performance Test:
/opt/kafka/bin/kafka-consumer-perf-test.sh --bootstrap-server=%{ for ip in aws_instance.ec2broker.*.private_ip ~}${ip}:9092%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.private_ip)-1] ~},%{ endif ~} %{ endfor ~} --messages 4000000 --topic test

kafka cluster public ips:
%{ for ip in aws_instance.ec2broker.*.public_ip ~}${ip}:9094%{ if ip != aws_instance.ec2broker.*.private_ip[length(aws_instance.ec2broker.*.public_ip)-1] ~},%{ endif ~} %{ endfor ~}

  EOT
  filename = "commands.txt"
}