data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
    owners = ["099720109477"] # Canonical official
}

resource "aws_instance" "ec2broker" {
  count                  = var.kafka_configuration["kafka_count"]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.kafka_configuration["instance_type"]
  subnet_id              = var.kafka_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"

  root_block_device {
    volume_size           = var.kafka_configuration["ephemeral"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname kafka-broker${count.index + 1}
  EOF
  tags = {
    Name = "kafka${count.index + 1}"
  }
}

resource "aws_instance" "ec2zoo" {
  count                  = var.zoo_configuration["zoo_count"]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.zoo_configuration["instance_type"]
  subnet_id              = var.zoo_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"

  root_block_device {
    volume_size           = var.zoo_configuration["ephemeral"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname zookeeper${count.index + 1}
  EOF
  tags = {
    Name = "zookeeper${count.index + 1}"
  }

}

resource "aws_instance" "ec2connect" {
  count                  = var.connect_configuration["connect_count"]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.connect_configuration["instance_type"]
  subnet_id              = var.connect_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"
  depends_on             = [aws_s3_bucket.connect_s3bucket, aws_s3_bucket_public_access_block.connect_s3bucket_public_access, aws_s3_bucket_policy.connect_s3bucket_policy]
  
  root_block_device {
    volume_size           = var.connect_configuration["ephemeral"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname kafka-connect${count.index + 1}
  EOF

  tags = {
    Name = "kafka-connect${count.index + 1}"
  }

}

resource "aws_instance" "ec2mm" {
  count                  = var.mm_configuration["mm_count"]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.mm_configuration["instance_type"]
  subnet_id              = var.mm_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"

  root_block_device {
    volume_size           = var.mm_configuration["ephemeral"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname mm${count.index + 1}
  EOF
  tags = {
    Name = "mirror-maker${count.index + 1}"
  }

}

resource "aws_instance" "ec2schemareg" {
  count                  = var.schema_configuration["schema_count"]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.schema_configuration["instance_type"]
  subnet_id              = var.schema_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"
  
  root_block_device {
    volume_size           = var.schema_configuration["ephemeral"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname schema-registry${count.index + 1}
  EOF

  tags = {
    Name = "schema-registry${count.index + 1}"
  }

}

resource "aws_instance" "ec2cruise" {
  count                  = var.cruise_configuration["cruise_deploy"] != "true" ? 0 : 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.cruise_configuration["instance_type"]
  subnet_id              = var.cruise_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"
  
  root_block_device {
    volume_size           = var.cruise_configuration["ephemeral"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname cruise-control
  EOF

  tags = {
    Name = "cruise-control"
  }

}

resource "aws_instance" "ec2provectus" {
  count                  = var.provectus_ui_configuration["provectus_deploy"] != "true" ? 0 : 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.provectus_ui_configuration["instance_type"]
  subnet_id              = var.provectus_ui_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"
  
  root_block_device {
    volume_size           = var.provectus_ui_configuration["ephemeral"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname kafka-ui
  EOF

  tags = {
    Name = "kafka-ui"
  }

}

resource "aws_instance" "ec2prometheus" {
  count                  = var.prometheus_configuration["prom_count"] > 0 ? 1 : 0
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.prometheus_configuration["instance_type"]
  subnet_id              = var.prometheus_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"

  root_block_device {
    volume_size           = var.prometheus_configuration["disk"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname prometheus${count.index + 1}
EOF
  tags = {
    Name = "prometheus${count.index + 1}"
  }

}

resource "aws_instance" "ec2grafana" {
  count                  = var.prometheus_configuration["prom_count"] > 0 ? 1 : 0
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.grafana_configuration["instance_type"]
  subnet_id              = var.grafana_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"

  root_block_device {
    volume_size           = var.grafana_configuration["disk"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname grafana${count.index + 1}
EOF
  tags = {
    Name = "grafana${count.index + 1}"
  }

}

resource "aws_instance" "ec2mysqldb" {
  count                  = var.mysqldb_configuration["mysqldb_deploy"] != "true" ? 0 : 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.mysqldb_configuration["instance_type"]
  subnet_id              = var.mysqldb_configuration["subnet"] != "public" ? aws_subnet.private_subnet[0].id : aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  iam_instance_profile   = "SSMforEC2"

  root_block_device {
    volume_size           = var.mysqldb_configuration["disk"]
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname mysql${count.index + 1}
EOF
  tags = {
    Name = "mysql${count.index + 1}"
  }

}
