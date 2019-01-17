provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_vpc" "incepter" {
  cidr_block = "172.16.0.0/16"
  enable_dns_hostnames = true
  tags {
    Name = "incepter VPC"
  }
}

resource "aws_subnet" "incepter" {
  vpc_id                  = "${aws_vpc.incepter.id}"
  cidr_block              = "${var.cidr_block}"
  availability_zone       = "${var.zone}"
  map_public_ip_on_launch = true 
  tags {
    Name = "incepter"
  }
}

resource "aws_internet_gateway" "incepter" {
  vpc_id = "${aws_vpc.incepter.id}"
}

resource "aws_route_table" "incepter" {
  vpc_id = "${aws_vpc.incepter.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.incepter.id}"
  }
}

resource "aws_route_table_association" "incepter" {
    subnet_id = "${aws_subnet.incepter.id}"
    route_table_id = "${aws_route_table.incepter.id}"
}

resource "aws_security_group" "incepter" {
    name = "incepter web host"
    description = "Allow http inbound/outbound for Internet and ssh inbound from provisioner."
    vpc_id = "${aws_vpc.incepter.id}"
    # Open http inbound to Internet
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Open ssh inbound to the provisioning machine
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.management_ip.body)}/32"]
    }

    # Unrestricted outbound
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "tls_private_key" "incepter" {
  algorithm = "RSA"
  rsa_bits = "4096"

  provisioner "local-exec" {
    command = "echo -n ${jsonencode(self.private_key_pem)} > incepter"
  }

  provisioner "local-exec" {
    command = "echo -n ${jsonencode(self.public_key_openssh)} > incepter.pub"
  }

  provisioner "local-exec" {
    command = "sudo chmod 600 incepter"
  }
}

resource "aws_key_pair" "incepter" {
  key_name   = "incepter-key"
  public_key = "${tls_private_key.incepter.public_key_openssh}"
}

resource "aws_instance" "incepter" {
  ami           = "${data.aws_ami.ubuntu_xenial.id}"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.incepter.key_name}"
  tags {
    Name = "incepter node"
  }

  subnet_id = "${aws_subnet.incepter.id}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.incepter.id}"]

  provisioner "file" {
    source = "scripts"
    destination = "/home/ubuntu/"
    connection {
      user = "ubuntu"
      private_key = "${tls_private_key.incepter.private_key_pem}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y curl",
      "sudo apt-get install -y unzip"
    ]
    connection {
      user = "ubuntu"
      private_key = "${tls_private_key.incepter.private_key_pem}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/scripts/install-terraform.sh",
      "sudo /home/ubuntu/scripts/install-terraform.sh"
    ]
    connection = {
      host = "${self.public_ip}"
      user = "ubuntu"
      private_key = "${tls_private_key.incepter.private_key_pem}"
    }
  }
}

# Output incepter instance public IP
output "incepter-ip" {
  value = "${aws_instance.incepter.public_ip}"
}
