
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "ap-south-1"
}

data "aws_security_group" "sec_group" {
  id = "${var.security_group}"
}

output "vpc_id" { value = "${data.aws_security_group.sec_group.vpc_id}" }

resource "aws_key_pair" "deployer" {
  key_name = "${var.key_name}" 
  public_key = "${var.public_key}"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  security_groups = [ "${data.aws_security_group.sec_group.name}" ]
  tags {
    Name = "terraform-crashcourse"
  }
}
