resource "aws_ebs_volume" "ebsbroker" {
    count = var.kafka_configuration["kafka_count"]
    availability_zone = var.subnet_availability_zones[0]
    type = var.kafka_configuration["persistent_type"]
    size = var.kafka_configuration["persistent"]
    tags = {
        Name = "kafka-volume${count.index + 1}"
    }    
}

resource "aws_ebs_volume" "ebszoo" {
    count = var.zoo_configuration["zoo_count"]
    availability_zone = var.subnet_availability_zones[0]
    type = var.zoo_configuration["persistent_type"]
    size = var.zoo_configuration["persistent"]
    tags = {
        Name = "zookeeper-volume${count.index + 1}"
    }    
}

resource "aws_ebs_volume" "ebsmm" {
    count = var.mm_configuration["mm_count"]
    availability_zone = var.subnet_availability_zones[0]
    type = var.mm_configuration["persistent_type"]
    size = var.mm_configuration["persistent"]
    tags = {
        Name = "mirrormaker-volume${count.index + 1}"
    }    
}

resource "aws_ebs_volume" "ebsconnect" {
    count = var.connect_configuration["connect_count"]
    availability_zone = var.subnet_availability_zones[0]
    type = var.connect_configuration["persistent_type"]
    size = var.connect_configuration["persistent"]
    tags = {
        Name = "connect-volume${count.index + 1}"
    }    
}

resource "aws_ebs_volume" "ebsschema" {
    count = var.schema_configuration["schema_count"]
    availability_zone = var.subnet_availability_zones[0]
    type = var.schema_configuration["persistent_type"]
    size = var.schema_configuration["persistent"]
    tags = {
        Name = "schema-volume${count.index + 1}"
    }    
}

resource "aws_ebs_volume" "ebscruise" {
    count = var.cruise_configuration["cruise_deploy"] != "true" ? 0 : 1
    availability_zone = var.subnet_availability_zones[0]
    type = var.cruise_configuration["persistent_type"]
    size = var.cruise_configuration["persistent"]
    tags = {
        Name = "cruise-volume${count.index + 1}"
    }    
}

resource "aws_ebs_volume" "ebsprovectus" {
    count = var.provectus_ui_configuration["provectus_deploy"] != "true" ? 0 : 1
    availability_zone = var.subnet_availability_zones[0]
    type = var.provectus_ui_configuration["persistent_type"]
    size = var.provectus_ui_configuration["persistent"]
    tags = {
        Name = "provectus-volume${count.index + 1}"
    }    
}

########### ATTACHMENT ###################

resource "aws_volume_attachment" "ebs_att_broker" {
    count = var.kafka_configuration["kafka_count"]
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.ebsbroker[count.index].id
    instance_id = aws_instance.ec2broker[count.index].id
}

resource "aws_volume_attachment" "ebs_att_zoo" {
    count = var.zoo_configuration["zoo_count"]
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.ebszoo[count.index].id
    instance_id = aws_instance.ec2zoo[count.index].id
}

resource "aws_volume_attachment" "ebs_att_mm" {
    count = var.mm_configuration["mm_count"]
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.ebsmm[count.index].id
    instance_id = aws_instance.ec2mm[count.index].id
}

resource "aws_volume_attachment" "ebs_att_connect" {
    count = var.connect_configuration["connect_count"]
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.ebsconnect[count.index].id
    instance_id = aws_instance.ec2connect[count.index].id
}

resource "aws_volume_attachment" "ebs_att_schema" {
    count = var.schema_configuration["schema_count"]
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.ebsschema[count.index].id
    instance_id = aws_instance.ec2schemareg[count.index].id
}

resource "aws_volume_attachment" "ebs_att_cruise" {
    count = var.cruise_configuration["cruise_deploy"] != "true" ? 0 : 1
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.ebscruise[count.index].id
    instance_id = aws_instance.ec2cruise[count.index].id
}

resource "aws_volume_attachment" "ebs_att_provectus" {
    count = var.provectus_ui_configuration["provectus_deploy"] != "true" ? 0 : 1
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.ebsprovectus[count.index].id
    instance_id = aws_instance.ec2provectus[count.index].id
}