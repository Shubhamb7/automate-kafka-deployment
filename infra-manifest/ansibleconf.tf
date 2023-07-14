locals {
  zoo = var.zoo_configuration["zoo_count"]
  kafka = var.kafka_configuration["kafka_count"]
  mm = var.mm_configuration["mm_count"]
  conn = var.connect_configuration["connect_count"]
  schema = var.schema_configuration["schema_count"]
  cruise = var.cruise_configuration["cruise_deploy"] != "true" ? 0 : 1
  provectus = var.provectus_ui_configuration["provectus_deploy"] != "true" ? 0 : 1
  prometheus = var.prometheus_configuration["prom_count"] > 0 ? 1 : 0
  grafana = var.prometheus_configuration["prom_count"] > 0 ? 1 : 0
}

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
 
%{ if local.mm > 0 ~}
[mm]
%{ for ip in aws_instance.ec2mm.*.private_ip ~}
${ip}
%{ endfor ~}
%{ endif ~} 

%{ if local.conn > 0 ~}
[connect]
%{ for ip in aws_instance.ec2connect.*.private_ip ~}
${ip}
%{ endfor ~}
%{ endif ~} 

%{ if local.schema > 0 ~}
[schemareg]
%{ for ip in aws_instance.ec2schemareg.*.private_ip ~}
${ip}
%{ endfor ~}
%{ endif ~} 
 
%{ if local.cruise > 0 ~}
[cruise]
%{ for ip in aws_instance.ec2cruise.*.private_ip ~}
${ip}
%{ endfor ~}
%{ endif ~} 
 
%{ if local.provectus > 0 ~}
[provectus]
%{ for ip in aws_instance.ec2provectus.*.private_ip ~}
${ip}
%{ endfor ~}
%{ endif ~} 
 
%{ if local.prometheus > 0 ~}
[prometheus]
%{ for ip in aws_instance.ec2prometheus.*.private_ip ~}
${ip}
%{ endfor ~}
%{ endif ~} 
 
%{ if local.grafana > 0 ~}
[grafana]
%{ for ip in aws_instance.ec2grafana.*.private_ip ~}
${ip}
%{ endfor ~}
%{ endif ~} 
 
  EOT
  filename = "./ansible/hosts"
}

resource "local_file" "mm_properties" {
  count = var.mm_configuration["mm_count"] > 0 ? 1 : 0
  content = <<EOT
# specify any number of cluster aliases
clusters = A, B

# connection information for each cluster
# This is a comma separated host:port pairs for each cluster
# for e.g. "A_host1:9092, A_host2:9092, A_host3:9092"
A.bootstrap.servers = %{ for i, ip in aws_instance.ec2broker.*.public_ip ~}${ip}:9094%{ if i != length(aws_instance.ec2broker.*.public_ip) - 1 ~},%{ endif ~}%{ endfor ~}

B.bootstrap.servers = 

A->B.enabled = true
A->B.topics = .*
A->B.groups = .*

#B->A.enabled = true
#B->A.topics = .*
#B->A.groups = .*

# Setting replication factor of newly created remote topics
replication.factor = 2

############################# Internal Topic Settings  #############################

# The replication factor for mm2 internal topics "heartbeats", "B.checkpoints.internal" and
# "mm2-offset-syncs.B.internal"
# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3.
checkpoints.topic.replication.factor = 1
heartbeats.topic.replication.factor = 1
offset-syncs.topic.replication.factor = 1

# The replication factor for connect internal topics "mm2-configs.B.internal", "mm2-offsets.B.internal" and
# "mm2-status.B.internal"
# For anything other than development testing, a value greater than 1 is recommended to ensure availability such as 3.
offset.storage.replication.factor = 1
status.storage.replication.factor = 1
config.storage.replication.factor = 1

# customize as needed
# replication.policy.separator = _
# sync.topic.acls.enabled = false
emit.checkpoints.interval.seconds = 5
emit.heartbeats.enabled = true
emit.heartbeats.interval.seconds = 5
EOT

  filename   = "./ansible/connect-mirror-maker.properties"
  depends_on = [aws_instance.ec2broker, aws_instance.ec2mm]
}
 
resource "local_file" "capacityJBOD" {
  count = local.cruise > 0 ? 1 : 0
  content = <<EOT
  {
    "brokerCapacities":[
      {
        "brokerId": "-1",
        "capacity": {
          "DISK": {"/opt/kafkadata/kafka-logs": "${ var.kafka_configuration["ephemeral"] }000"},
          "CPU": "2",
          "NW_IN": "5000",
          "NW_OUT": "5000"
        },
        "doc": "The default capacity for a broker with multiple logDirs each on a separate heterogeneous disk."
      }
    ]
  }
  EOT
  filename   = "./ansible/capacityJBOD.json"
  depends_on = [aws_instance.ec2broker]
}

resource "local_file" "capacityCores" {
  count = local.cruise > 0 ? 1 : 0
  content = <<EOT
  {
    "brokerCapacities":[
      {
        "brokerId": "-1",
        "capacity": {
          "DISK": "${ var.kafka_configuration["ephemeral"] }000",
          "CPU": {"num.cores": "2"},
          "NW_IN": "10000",
          "NW_OUT": "10000"
        },
        "doc": "This is the default capacity. Capacity unit used for disk is in MB, cpu is in number of cores, network throughput is in KB."
      }
    ]
  }
  EOT
  filename   = "./ansible/capacityCores.json"
  depends_on = [aws_instance.ec2broker]
}