profile    = "default"
env        = "kafka"
aws_region = "us-west-1"

keypair = "kafkacali"
userssh = "ubuntu"
key_path = "~/Downloads/"

vpc_cidr_block = "10.25.0.0/16"
subnet_availability_zones = ["us-west-1a"]
public_subnet_cidr        = ["10.25.1.0/24"]
private_subnet_cidr       = ["10.25.2.0/24"]

kafka_configuration = {
    "kafka_count" = 3,
    "instance_type" = "t2.medium",
    "ephemeral" = 30,
    "persistent" = 100,
    "persistent_type" = "gp2",
    "subnet" = "public",
    "sg" = "kafkaSG"
}

zoo_configuration = {
    "zoo_count" = 3,
    "instance_type" = "t2.medium",
    "ephemeral" = 30,
    "persistent" = 60,
    "persistent_type" = "gp2",
    "subnet" = "public",
    "sg" = "kafkaSG"
}

mm_configuration = {
    "mm_count" = 0,
    "instance_type" = "t2.medium",
    "ephemeral" = 30,
    "persistent" = 50,
    "persistent_type" = "gp2",
    "subnet" = "public",
    "sg" = "kafkaSG"
}

connect_configuration = {
    "connect_count" = 0,
    "instance_type" = "t2.medium",
    "ephemeral" = 30,
    "persistent" = 50,
    "persistent_type" = "gp2",
    "subnet" = "public",
    "sg" = "kafkaSG",
    "s3bucket_name" = "kafka-connect-s3-test-west-1"
}

schema_configuration = {
    "schema_count" = 0,
    "instance_type" = "t2.medium",
    "ephemeral" = 30,
    "persistent" = 50,
    "persistent_type" = "gp2",
    "subnet" = "public",
    "sg" = "kafkaSG"
}

cruise_configuration = {
    "cruise_deploy" = "false",
    "instance_type" = "t2.medium",
    "ephemeral" = 30,
    "persistent" = 30,
    "persistent_type" = "gp2",
    "subnet" = "public",
    "sg" = "kafkaSG"
}

provectus_ui_configuration = {
    "provectus_deploy" = "false",
    "instance_type" = "t2.medium",
    "ephemeral" = 30,
    "persistent" = 30,
    "persistent_type" = "gp2",
    "subnet" = "public",
    "sg" = "kafkaSG"
}

# For prometheus enter count 0 or 1

prometheus_configuration = {
    "prom_count" = 0,
    "instance_type" = "t2.large",
    "disk" = 40,
    "subnet" = "public",
    "sg" = "kafkaSG"
}

grafana_configuration = {
    "instance_type" = "t2.medium",
    "disk" = 25,
    "subnet" = "public",
    "sg" = "kafkaSG"
}