variable "os_type" {
  default = "rhel8"
}

variable "instance_count" {
  default = 1
}

variable key_path {
  default = "/home/ec2-user"
}

variable "private_key" {
  default = "rd_ssh_key.pem"
}

variable "ansible_user" {
  default = "ec2-user"
}

variable "key_pair_name" {
  default = "ibm-rd-coe-kp1"
}

variable "my_region" {
  default = "us-west-1"
}

variable "rhel7_instance" {
  type = object({
    region = string
    ami = string
    ansible_user = string
  })
  default = {
    region = "us-west-1"
    ami = ""
    ansible_user = "ec2-user"
  }
}

variable "rhel8_instance" {
  type = object({
    region = string
    ami = string
    ansible_user = string
  })
  default = {
    region = "us-west-1"
    ami = ""
    ansible_user = "ec2-user"
  }
}

variable "sles15_instance" {
  type = object({
    region = string
    ami = string
    ansible_user = string
  })
  default = {
    region = "us-west-1"
    ami = ""
    ansible_user = "ec2-user"
  }
}

variable "win2016_instance" {
  type = object({
    region = string
    ami = string
    ansible_user = string
    ansible_password = string
  })
  default = {
    region = "us-west-1"
    ami = ""
    ansible_user = "Administrator"
    ansible_password = ""
  }
}

variable "my_tags" {
  type = map
  default = {
    Owner  = "rd"
    Project = "On-boarding_Automation" 
    Location = "N.California"
  }
}

