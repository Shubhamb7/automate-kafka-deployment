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
 
[mm]
%{ for ip in aws_instance.ec2mm.*.private_ip ~}
${ip}
%{ endfor ~}
 
[provectus]
%{ for ip in aws_instance.ec2provectus.*.private_ip ~}
${ip}
%{ endfor ~}
 
  EOT
  filename = "./ansible/hosts"
}
 
resource "local_file" "mm_properties" {
  content = <<EOT
# specify any number of cluster aliases
clusters = A, B
# connection information for each cluster
# This is a comma separated host:port pairs for each cluster
# for e.g. "A_host1:9092, A_host2:9092, A_host3:9092"
A.bootstrap.servers = ${ aws_instance.ec2broker[0].public_ip }:9094,${ aws_instance.ec2broker[1].public_ip }:9094,${ aws_instance.ec2broker[2].public_ip }:9094
B.bootstrap.servers = 
A->B.enabled = true
A->B.topics = .*
A->B.groups = .*
#B->A.enabled = true
#B->A.topics = .*
#B->A.groups = .*
# Setting replication factor of newly created remote topics
replication.factor=2
############################# Internal Topic Settings  #############################
# The replication factor for mm2 internal topics "heartbeats", "B.checkpoints.internal" and
# "mm2-offset-syncs.B.internal"
# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3.
checkpoints.topic.replication.factor=1
heartbeats.topic.replication.factor=1
offset-syncs.topic.replication.factor=1
# The replication factor for connect internal topics "mm2-configs.B.internal", "mm2-offsets.B.internal" and
# "mm2-status.B.internal"
# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3.
offset.storage.replication.factor=1
status.storage.replication.factor=1
config.storage.replication.factor=1
# customize as needed
# replication.policy.separator = _
# sync.topic.acls.enabled = false
emit.checkpoints.interval.seconds = 5
emit.heartbeats.enabled = true
emit.heartbeats.interval.seconds = 5
  EOT
  filename = "./ansible/connect-mirror-maker.properties"
  depends_on = [
    aws_instance.ec2broker, aws_instance.ec2mm
  ]
}
