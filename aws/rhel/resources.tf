# Terraform script for Ansible AWS test environment
# This script is used to create RHEL endpoint server in ansible test environment
# Update AWS CLI profile name with the correct profile name for your environment

provider "aws" {
  profile= "default"
  region = "us-west-1"
}

resource "random_string" "random" {
  length = 5
  special = false
}

locals {
  rhel_user = "${var.os_type == "rhel8" ? var.rhel8_instance.ansible_user : var.rhel7_instance.ansible_user}"
}

resource "aws_instance" "Ansible-RHELserver" {
  count = "${(var.os_type == "rhel8" || var.os_type == "rhel7") ? var.instance_count : 0}"
  ami = "${var.os_type == "rhel8" ? var.rhel8_instance.ami : var.rhel7_instance.ami}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-08274e85fdfd2dd5d"]
  subnet_id = "subnet-0d4dcb7800e860bea"
  key_name = var.key_pair_name
  tags = { Name="RHEL-Ansible-Endpoint-${random_string.random.result}-${count.index}",
           Owner="PublicCloudCoE",
           AutoStop="True"}

  provisioner "remote-exec" {
    connection {
      host = "${self.private_dns}"
      type = "ssh"
      user = local.rhel_user
      private_key = "${file(var.private_key)}"
    }
    inline = [ "echo 'connected !'" ]
  }
}

resource "aws_instance" "Ansible-SLESserver" {
  count = "${var.os_type == "sles15" ? var.instance_count : 0}"
  ami = var.sles15_instance.ami
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-08274e85fdfd2dd5d"]
  subnet_id = "subnet-0d4dcb7800e860bea"
  key_name = var.key_pair_name
  tags = { Name="SLES-Ansible-Endpoint-${random_string.random.result}-${count.index}",
           Owner="PublicCloudCoE",
           AutoStop="True"}

  provisioner "remote-exec" {
    connection {
      host = "${self.private_dns}"
      type = "ssh"
      user = var.sles15_instance.ansible_user
      private_key = "${file(var.private_key)}"
    }
    inline = [ "echo 'connected !'" ]
  }
}

resource "aws_instance" "Ansible-Windowsserver" {
  count = "${var.os_type == "win2016" ? var.instance_count : 0}"
  ami = var.win2016_instance.ami
  instance_type = "t2.micro"
  vpc_security_group_ids = [ "sg-08274e85fdfd2dd5d" ]
  subnet_id = "subnet-0d4dcb7800e860bea"
  key_name = var.key_pair_name
  get_password_data = "true"
  user_data = "${file("win_user_data.txt")}"
  tags = { Name="Windows-Ansible-Endpoint-${random_string.random.result}-${count.index}",
           Owner="PublicCloudCoE",
           AutoStop="True"}

  connection {
    host = "${self.private_dns}"
    type = "winrm"
    insecure = "true"
    user = var.win2016_instance.ansible_user
    password = "${rsadecrypt(self.password_data, file(var.private_key))}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Instance connected",
      "net user ${var.win2016_instance.ansible_user} \"${var.win2016_instance.ansible_password}\""
    ]
  }
}

data "aws_instance" "private_ips_lin" {
  count               = length(aws_instance.Ansible-RHELserver)
  instance_id         = aws_instance.Ansible-RHELserver[count.index].id
}

resource "local_file" "inventory_hosts_lin" {
  count = (var.instance_count > 0 ? 1 : 0)
  content = "[${var.os_type}]\n${join("\n", formatlist("%s", aws_instance.Ansible-RHELserver.*.private_dns))}\n\n[${var.os_type}:vars]\nansible_user=${local.rhel_user}\nansible_ssh_private_key_file=${var.private_key}"
  filename = "inventory_hosts"
}

data "aws_instance" "ips_win" {
  count         = length(aws_instance.Ansible-Windowsserver)
  instance_id   = aws_instance.Ansible-Windowsserver[count.index].id
}

resource "local_file" "inventory_hosts_win" {
  count = (var.instance_count > 0 ? 1: 0)
  content = "[${var.os_type}]\n${join("\n", formatlist("%s", aws_instance.Ansible-Windowsserver.*.private_dns))}\n\n[${var.os_type}:vars]\nansible_user=${var.win2016_instance.ansible_user}\nansible_password=${var.win2016_instance.ansible_password}\nansible_connection=winrm\nansible_port=5985\nansible_winrm_server_cert_validation=ignore"
  filename = "inventory_hosts"
}

data "aws_instance" "ips_sles" {
  count = length(aws_instance.Ansible-SLESserver)
  instance_id = aws_instance.Ansible-SLESserver[count.index].id
}

resource "local_file" "inventory_hosts_sles" {
  count = (var.instance_count > 0 ? 1 : 0)
  content = "[${var.os_type}]\n${join("\n", formatlist("%s", aws_instance.Ansible-SLESserver.*.private_dns))}\n\n[${var.os_type}:vars]\nansible_user=${var.rhel8_instance.ansible_user}\nansible_ssh_private_key_file=${var.private_key}"
  filename = "inventory_hosts"
}

