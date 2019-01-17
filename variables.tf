# store the current machine's external ip
data "http" "management_ip" {
  url = "http://ipinfo.io/ip"
}

/* References:
 https://www.terraform.io/docs/providers/aws/d/ami.html
 http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html
 https://cloud-images.ubuntu.com/locator/ec2/
*/
data "aws_ami" "ubuntu_xenial" {
  # Ubuntu 16.04 LTS hvm:ebs-ssd
  most_recent = true

  filter {
    name = "name" 
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

variable "cidr_block" {
  default = "172.16.10.0/24"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "zone" {
  default = "us-west-2a"
}