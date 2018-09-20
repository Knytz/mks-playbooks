variable "aws_api_key" {}
variable "aws_api_secret" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  access_key = "${var.aws_api_key}"
  secret_key = "${var.aws_api_secret}"
  region     = "eu-west-1"
}

resource "aws_instance" "openmrs_cd_host" {
  ami           = "ami-00d26e4d09d30c72e"
  instance_type = "t2.micro"
  security_groups = [
        "Ping",
        "SSH",
        "HTTP / HTTPS"
  ]
  tags = {
    Name = "[TEST] [Terraform] [CentOS_7] [OpenMRS CD]",
    Type = "test",
    Owner = "${data.aws_caller_identity.current.user_id}",
    Group = "openmrs_cd_host",
    User = "centos",
    Common_Name = "openmrs-cd.test.vpn.mekomsolutions.net",
    Domain_Name = "openmrs-cd.test.mekomsolutions.net"
  }
}

resource "aws_instance" "docker_host" {
  ami           = "ami-00d26e4d09d30c72e"
  instance_type = "t2.micro"
  security_groups = [
        "Ping",
        "SSH",
        "HTTP / HTTPS"
  ]
  tags = {
    Name = "[TEST] [Terraform] [CentOS_7] [Docker Host]",
    Type = "test",
    Owner = "${data.aws_caller_identity.current.user_id}",
    Group = "docker_host",
    User = "centos",
    Common_Name = "docker-host-01.test.vpn.mekomsolutions.net",
    Domain_Name = "docker-host-01.test.mekomsolutions.net"
  }
}

output "openmrs_cd_host_stats" {
  value = {
    ip = "${aws_instance.openmrs_cd_host.public_ip}",
    group = "${aws_instance.openmrs_cd_host.tags.Group}"
    user = "${aws_instance.openmrs_cd_host.tags.User}"
    common_name = "${aws_instance.openmrs_cd_host.tags.Common_Name}"
    domain_name = "${aws_instance.openmrs_cd_host.tags.Domain_Name}"
  }
}
output "docker_host_stats" {
  value = {
    ip = "${aws_instance.docker_host.public_ip}",
    group = "${aws_instance.docker_host.tags.Group}",
    user = "${aws_instance.docker_host.tags.User}"
    common_name = "${aws_instance.docker_host.tags.Common_Name}"
    domain_name = "${aws_instance.docker_host.tags.Domain_Name}"
  }
}

