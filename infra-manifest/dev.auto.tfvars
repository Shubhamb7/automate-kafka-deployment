profile    = "default"
env        = "kafka"
aws_region = "us-east-1"

keypair = "terraform-test"
userssh = "ubuntu"
key_path = "~/Downloads/"

vpc_cidr_block = "10.25.0.0/16"
subnet_availability_zones = ["us-east-1a"]
public_subnet_cidr        = ["10.25.1.0/24"]
private_subnet_cidr       = ["10.25.2.0/24"]

kafka_configuration = {
    "kafka_count" = 3,
    "instance_type" = "t2.medium",
    "disk" = 40,
    "subnet" = "public",
    "sg" = "kafkaSG"
}

zoo_configuration = {
    "zoo_count" = 3,
    "instance_type" = "t2.medium",
    "disk" = 25,
    "subnet" = "public",
    "sg" = "kafkaSG"
}

mm_configuration = {
    "mm_count" = 1,
    "instance_type" = "t2.medium",
    "disk" = 25,
    "subnet" = "public",
    "sg" = "kafkaSG"
}

connect_configuration = {
    "connect_count" = 1,
    "instance_type" = "t2.medium",
    "disk" = 25,
    "subnet" = "public",
    "sg" = "kafkaSG",
    "s3bucket_name" = "kafka-connect-s3-test-east-1"
}

schema_configuration = {
    "schema_count" = 0,
    "instance_type" = "t2.medium",
    "disk" = 25,
    "subnet" = "public",
    "sg" = "kafkaSG"
}

cruise_configuration = {
    "cruise_deploy" = "false",
    "instance_type" = "t2.medium",
    "disk" = 30,
    "subnet" = "public",
    "sg" = "kafkaSG"
}

provectus_ui_configuration = {
    "provectus_deploy" = "true",
    "instance_type" = "t2.medium",
    "disk" = 30,
    "subnet" = "public",
    "sg" = "kafkaSG"
}

# For prometheus enter count 0 or 1

prometheus_configuration = {
    "prom_count" = 1,
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

