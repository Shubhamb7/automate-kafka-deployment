resource "aws_instance" "ansible" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = var.keypair
  depends_on             = [local_file.ansible_hosts, aws_instance.ec2broker, aws_instance.ec2zoo]
  iam_instance_profile   = "SSMforEC2"
  tags = {
    Name = "ansible-node"
  }
  provisioner "file" {
    source      = "${var.key_path}${var.keypair}.pem"
    destination = "${var.keypair}.pem"
  }
  connection {
    type = "ssh"
    user = var.userssh
    private_key = file("${var.key_path}\\${var.keypair}.pem")
    host = self.public_dns
  }
  provisioner "local-exec" {
    command = "scp -i ${var.key_path}${var.keypair}.pem -o StrictHostKeyChecking=no -r ./ansible/* ubuntu@${self.public_dns}:~/"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get install software-properties-common -y",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get install ansible -y",
      "sudo mv ${var.keypair}.pem /tmp/${var.keypair}.pem",
      "sudo chmod 400 /tmp/${var.keypair}.pem",
      "sudo rm /etc/ansible/ansible.cfg && sudo mv config/ansible.cfg /etc/ansible/ansible.cfg",
      "sudo rm /etc/ansible/hosts && sudo mv config/hosts /etc/ansible/hosts",
      "sudo rm -rf config/",
      "sudo mkdir /opt/kafka-ansible && sudo mv * /opt/kafka-ansible/",
      "cd /opt/kafka-ansible/ && sudo ln -s ../roles/ playbooks/",
      "ansible-playbook /opt/kafka-ansible/playbooks/setup.yml --private-key /tmp/${var.keypair}.pem"
    ]
  }
}

