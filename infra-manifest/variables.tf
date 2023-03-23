variable "profile" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "env" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "public_subnet_cidr" {
  type = list(any)
}

variable "private_subnet_cidr" {
  type = list(any)
}

variable "subnet_availability_zones" {
  type = list(any)
}

variable "kafka_configuration" {
  type = map(any)
}

variable "zoo_configuration" {
  type = map(any)
}

variable "mm_configuration" {
  type = map(any)
}

variable "connect_configuration" {
  type = map(any)
}

variable "schema_configuration" {
  type = map(any)
}

variable "cruise_configuration" {
  type = map(any)
}

variable "keypair" {
  type = string
}
variable "userssh" {
  type = string
}
variable "key_path" {
  type = string
}