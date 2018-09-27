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
        "HTTP / HTTPS",
        "Extended 8xxx port range"
  ]
  tags = {
    Name = "[TEST] [Terraform] [CentOS_7] [OpenMRS CD]",
    Type = "test",
    Owner = "${data.aws_caller_identity.current.user_id}",
    Group = "openmrs_cd_host",
    User = "centos",
    Common_Name = "openmrs-cd.test.vpn.mekomsolutions.net",
    Domain = "mekomsolutions.net",
    Subdomain = "openmrs-cd.test"
  }
}

resource "aws_instance" "docker_host" {
  ami           = "ami-00d26e4d09d30c72e"
  instance_type = "t2.micro"
  security_groups = [
        "Ping",
        "SSH",
        "HTTP / HTTPS",
        "Extended 8xxx port range"
  ]
  tags = {
    Name = "[TEST] [Terraform] [CentOS_7] [Docker Host]",
    Type = "test",
    Owner = "${data.aws_caller_identity.current.user_id}",
    Group = "docker_host",
    User = "centos",
    Common_Name = "docker-host-01.test.vpn.mekomsolutions.net",
    Domain = "mekomsolutions.net",
    Subdomain = "docker-host-01.test"
  }
}

resource "aws_instance" "vpn_server" {
  ami           = "ami-00d26e4d09d30c72e"
  instance_type = "t2.nano"
  security_groups = [
        "Ping",
        "SSH",
        "HTTP / HTTPS",
        "Extended 8xxx port range"
  ]
  tags = {
    Name = "[TEST] [Terraform] [CentOS_7] [VPN Server]",
    Type = "test",
    Owner = "${data.aws_caller_identity.current.user_id}",
    Group = "vpn_server",
    User = "centos",
    Common_Name = "vpn-server.test.vpn.mekomsolutions.net",
    Domain = "mekomsolutions.net",
    Subdomain = "vpn-server.test"
  }
}

output "openmrs_cd_host_stats" {
  value = {
    ip = "${aws_instance.openmrs_cd_host.public_ip}",
    group = "${aws_instance.openmrs_cd_host.tags.Group}"
    user = "${aws_instance.openmrs_cd_host.tags.User}"
    common_name = "${aws_instance.openmrs_cd_host.tags.Common_Name}"
    domain = "${aws_instance.openmrs_cd_host.tags.Domain}"
    subdomain = "${aws_instance.openmrs_cd_host.tags.Subdomain}"
  }
}
output "docker_host_stats" {
  value = {
    ip = "${aws_instance.docker_host.public_ip}",
    group = "${aws_instance.docker_host.tags.Group}",
    user = "${aws_instance.docker_host.tags.User}"
    common_name = "${aws_instance.docker_host.tags.Common_Name}"
    domain = "${aws_instance.docker_host.tags.Domain}"
    subdomain = "${aws_instance.docker_host.tags.Subdomain}"
  }
}
output "vpn_server_stats" {
  value = {
    ip = "${aws_instance.vpn_server.public_ip}",
    group = "${aws_instance.vpn_server.tags.Group}",
    user = "${aws_instance.vpn_server.tags.User}"
    common_name = "${aws_instance.vpn_server.tags.Common_Name}"
    domain = "${aws_instance.vpn_server.tags.Domain}"
    subdomain = "${aws_instance.vpn_server.tags.Subdomain}"
  }
}