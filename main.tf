# main.tf
#
# Dipl.-Ing. Andreas la Quiante
# Hamburg, 16-FEB-2018
#
# simplification for Round-Table Munich
# 20-JUN-2018

terraform {
  required_version = "= 0.11.2"
}

# First Provider AWS
#
#
provider "aws" {
  region     = "eu-central-1"
  access_key = "${var.a_key}"
  secret_key = "${var.s_key}"
}

resource "aws_vpc" "alq-01" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_vpc" "alq-02" {
  cidr_block = "10.2.0.0/16"
}

# IGW

resource "aws_internet_gateway" "igw-01" {
  vpc_id = "${aws_vpc.alq-01.id}"
}

resource "aws_internet_gateway" "igw-02" {
  vpc_id = "${aws_vpc.alq-02.id}"
}

# ---------------------------------------------------

resource "aws_vpc_peering_connection" "vpc-01_to_vpc-02" {
  vpc_id      = "${aws_vpc.alq-01.id}"
  peer_vpc_id = "${aws_vpc.alq-02.id}"
  auto_accept = true
}

#
# --------------------------------------------------------
#
# Subnets 11, 12, and 13
resource "aws_subnet" "subnet-11" {
  vpc_id = "${aws_vpc.alq-01.id}"

  cidr_block        = "10.1.1.0/24"
  availability_zone = "eu-central-1a"

  tags {
    Name = "Transit-VPC-01"
  }
}

resource "aws_subnet" "subnet-12" {
  vpc_id = "${aws_vpc.alq-01.id}"

  cidr_block        = "10.1.2.0/24"
  availability_zone = "eu-central-1a"

  tags {
    Name = "vrf-01"

    #Tenant = "Tenant-01"
  }
}

resource "aws_subnet" "subnet-13" {
  vpc_id = "${aws_vpc.alq-01.id}"

  cidr_block        = "10.1.3.0/24"
  availability_zone = "eu-central-1a"

  tags {
    Name = "vrf-02"

    #Tenant = "Tenant-02"
  }
}

# Subnets 21, 22, and 23
resource "aws_subnet" "subnet-21" {
  vpc_id = "${aws_vpc.alq-02.id}"

  cidr_block        = "10.2.1.0/24"
  availability_zone = "eu-central-1a"

  tags {
    Name = "Transit-VPC-02"
  }
}

resource "aws_subnet" "subnet-22" {
  vpc_id = "${aws_vpc.alq-02.id}"

  cidr_block        = "10.2.2.0/24"
  availability_zone = "eu-central-1a"

  tags {
    Name = "vrf-01"

    #Tenant = "Tenant-01"
  }
}

resource "aws_subnet" "subnet-23" {
  vpc_id = "${aws_vpc.alq-02.id}"

  cidr_block        = "10.2.3.0/24"
  availability_zone = "eu-central-1a"

  tags {
    Name = "vrf-02"

    #Tenant = "Tenant-02"
  }
}

#  Security group
#
# sg-alq-01
# sg-alq-02
#
# --------------------------------------------------------
#
# zum testen erstmal von überall her erlauben: SSH, HTTP, HTTPS, ICMP

resource "aws_security_group" "sg-alq-01" {
  vpc_id      = "${aws_vpc.alq-01.id}"
  name        = "security-group-01"
  description = "sg-alq-01"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg-alq-02" {
  vpc_id      = "${aws_vpc.alq-02.id}"
  name        = "security-group-02"
  description = "sg-alq-02"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Routing Table creation and association
#
# rt-alq-11 und subnet-11
# rt-alq-12 und subnet-12
# rt-alq-13 und subnet-13

resource "aws_route_table" "rt-alq-11" {
  vpc_id = "${aws_vpc.alq-01.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw-01.id}"
  }

  route {
    cidr_block                = "10.2.1.0/24"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc-01_to_vpc-02.id}"
  }

  route {
    cidr_block                = "10.2.2.0/24"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc-01_to_vpc-02.id}"
  }

  route {
    cidr_block                = "10.2.3.0/24"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc-01_to_vpc-02.id}"
  }
}

resource "aws_route_table_association" "rt-subnet-11" {
  subnet_id      = "${aws_subnet.subnet-11.id}"
  route_table_id = "${aws_route_table.rt-alq-11.id}"
}

#
# -----------------------------------------------------
#

resource "aws_route_table" "rt-alq-12" {
  vpc_id = "${aws_vpc.alq-01.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw-01.id}"
  }

  route {
    cidr_block           = "10.2.0.0/16"
    network_interface_id = "${aws_network_interface.eth-12.id}"
  }
}

resource "aws_route_table_association" "rt-subnet-12" {
  subnet_id      = "${aws_subnet.subnet-12.id}"
  route_table_id = "${aws_route_table.rt-alq-12.id}"
}

#
# -----------------------------------------------------
#

#resource "aws_route_table" "rt-alq-13" {
#  vpc_id = "${aws_vpc.alq-01.id}"

  #    route {
  #        cidr_block = "0.0.0.0/0"
  #        gateway_id = "${aws_internet_gateway.igw-01.id}"
  #    }

#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = "${aws_internet_gateway.igw-01.id}"
#  }
#  route {
#    cidr_block           = "10.2.0.0/16"
#    network_interface_id = "${aws_network_interface.eth-13.id}"
#  }
#}

#resource "aws_route_table_association" "rt-subnet-13" {
#  subnet_id      = "${aws_subnet.subnet-13.id}"
#  route_table_id = "${aws_route_table.rt-alq-13.id}"
#}

#
# -----------------------------------------------------
#

resource "aws_route_table" "rt-alq-21" {
  vpc_id = "${aws_vpc.alq-02.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw-02.id}"
  }

  route {
    cidr_block                = "10.1.1.0/24"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc-01_to_vpc-02.id}"
  }

  route {
    cidr_block                = "10.1.2.0/24"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc-01_to_vpc-02.id}"
  }

  route {
    cidr_block                = "10.1.3.0/24"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc-01_to_vpc-02.id}"
  }

  #    route {
  #        cidr_block = "10.1.0.0/16"
  #        network_interface_id = "${aws_network_interface.eth-21.id}"
  #    }
}

resource "aws_route_table_association" "rt-subnet-21" {
  subnet_id      = "${aws_subnet.subnet-21.id}"
  route_table_id = "${aws_route_table.rt-alq-21.id}"
}

#
# -----------------------------------------------------
#

resource "aws_route_table" "rt-alq-22" {
  vpc_id = "${aws_vpc.alq-02.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw-02.id}"
  }

  route {
    #        cidr_block = "0.0.0.0/0"
    cidr_block           = "10.1.0.0/16"
    network_interface_id = "${aws_network_interface.eth-22.id}"
  }
}

resource "aws_route_table_association" "rt-subnet-22" {
  subnet_id      = "${aws_subnet.subnet-22.id}"
  route_table_id = "${aws_route_table.rt-alq-22.id}"
}

#
# -----------------------------------------------------
#

#resource "aws_route_table" "rt-alq-23" {
#  vpc_id = "${aws_vpc.alq-02.id}"

#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = "${aws_internet_gateway.igw-02.id}"
#  }

#  route {
#    #        cidr_block = "0.0.0.0/0"
#    cidr_block           = "10.1.0.0/16"
#    network_interface_id = "${aws_network_interface.eth-23.id}"
#  }
#}

#resource "aws_route_table_association" "rt-subnet-23" {
#  subnet_id      = "${aws_subnet.subnet-23.id}"
#  route_table_id = "${aws_route_table.rt-alq-23.id}"
#}

#
# -----------------------------------------------------
#

# Jumphost creation

#resource "aws_instance" "JH-01" {
#  ami                         = "ami-97e953f8"
#  instance_type               = "t2.micro"
#  key_name                    = "TEST-18-NOV"
#  availability_zone           = "eu-central-1a"
#  subnet_id                   = "${aws_subnet.subnet-11.id}"
#  vpc_security_group_ids      = ["${aws_security_group.sg-alq-01.id}"]
#  associate_public_ip_address = true
#  source_dest_check           = false
#
#  tags {
#    Name = "Jumphost-01"
#  }
#}

#resource "aws_instance" "JH-02" {
#  ami                         = "ami-97e953f8"
#  instance_type               = "t2.micro"
#  key_name                    = "TEST-18-NOV"
#  availability_zone           = "eu-central-1a"
#  subnet_id                   = "${aws_subnet.subnet-21.id}"
#  vpc_security_group_ids      = ["${aws_security_group.sg-alq-02.id}"]
#  associate_public_ip_address = true
#  source_dest_check           = false

#  tags {
#    Name = "Jumphost-02"
#  }
#}

# Instance creation
#
# Tenant-01: server-01 fuer subnet-12
# Tenant-02: server-02 fuer subnet-13
#
# vEOS-Router: fuer subnet-11

resource "aws_instance" "server-12" {
  ami                    = "ami-97e953f8"
  instance_type          = "t2.micro"
  key_name               = "TEST-18-NOV"
  availability_zone      = "eu-central-1a"
  subnet_id              = "${aws_subnet.subnet-12.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-alq-01.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Tenant-01 Server VPC alq-01" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "Tenant-Web-12"
  }
}

#resource "aws_instance" "server-13" {
#  ami                    = "ami-97e953f8"
#  instance_type          = "t2.micro"
#  key_name               = "TEST-18-NOV"
#  availability_zone      = "eu-central-1a"
#  subnet_id              = "${aws_subnet.subnet-13.id}"
#  vpc_security_group_ids = ["${aws_security_group.sg-alq-01.id}"]

#  user_data = <<-EOF
#              #!/bin/bash
#              echo "Tenant-02 Server VPC alq-01" > index.html
#              nohup busybox httpd -f -p "${var.server_port}" &
#              EOF

#  associate_public_ip_address = true
#  source_dest_check           = false
#
#  tags {
#    Name = "Tenant-Web-13"
#  }
#}

resource "aws_instance" "server-22" {
  ami                    = "ami-97e953f8"
  instance_type          = "t2.micro"
  key_name               = "TEST-18-NOV"
  availability_zone      = "eu-central-1a"
  subnet_id              = "${aws_subnet.subnet-22.id}"
  vpc_security_group_ids = ["${aws_security_group.sg-alq-02.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Tenant-01 DB VPC alq-02" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  associate_public_ip_address = true
  source_dest_check           = false

  tags {
    Name = "Tenant-DB-22"
  }
}

#resource "aws_instance" "server-23" {
#  ami                    = "ami-97e953f8"
#  instance_type          = "t2.micro"
#  key_name               = "TEST-18-NOV"
#  availability_zone      = "eu-central-1a"
#  subnet_id              = "${aws_subnet.subnet-23.id}"
#  vpc_security_group_ids = ["${aws_security_group.sg-alq-02.id}"]

#  user_data = <<-EOF
#              #!/bin/bash
#              echo "Tenant-02 DB VPC alq-02" > index.html
#              nohup busybox httpd -f -p "${var.server_port}" &
#              EOF

#  associate_public_ip_address = true
#  source_dest_check           = false

#  tags {
#    Name = "Tenant-DB-23"
#  }
#}

#
# -----------------------------------------------------
#

resource "aws_instance" "router-01" {
  ami           = "ami-67ee6c08"
  instance_type = "t2.medium"

  #  instance_type = "c4.xlarge"

  key_name                    = "TEST-18-NOV"
  availability_zone           = "eu-central-1a"
  subnet_id                   = "${aws_subnet.subnet-11.id}"
  vpc_security_group_ids      = ["${aws_security_group.sg-alq-01.id}"]
  associate_public_ip_address = true
  source_dest_check           = false
  private_ip                  = "10.1.1.8"
  user_data                   = "${file("/Users/alq/Documents/Infrastructure-as-Code/vEOS-Router/vRouter-startup-config-1.txt")}"

  tags {
    Name = "vEOS Router-01"
  }
}

resource "aws_network_interface" "eth-12" {
  subnet_id         = "${aws_subnet.subnet-12.id}"
  source_dest_check = false
  private_ips       = ["10.1.2.8"]
  security_groups   = ["${aws_security_group.sg-alq-01.id}"]
  depends_on = ["aws_instance.router-01"]

  attachment {
    instance     = "${aws_instance.router-01.id}"
    device_index = 1
  }
}

#resource "aws_network_interface" "eth-13" {
#  subnet_id         = "${aws_subnet.subnet-13.id}"
#  source_dest_check = false
#  private_ips       = ["10.1.3.8"]
#  security_groups   = ["${aws_security_group.sg-alq-01.id}"]
#  depends_on = ["aws_instance.router-01"]
#
#  attachment {
#    instance     = "${aws_instance.router-01.id}"
#    device_index = 2
#  }
#}

# ----------------------------------------

resource "aws_instance" "router-02" {
  ami           = "ami-67ee6c08"
  instance_type = "t2.medium"

  #  instance_type = "c4.xlarge"

  key_name                    = "TEST-18-NOV"
  availability_zone           = "eu-central-1a"
  subnet_id                   = "${aws_subnet.subnet-21.id}"
  vpc_security_group_ids      = ["${aws_security_group.sg-alq-02.id}"]
  associate_public_ip_address = true
  source_dest_check           = false
  private_ip                  = "10.2.1.8"
  user_data                   = "${file("/Users/alq/Documents/Infrastructure-as-Code/vEOS-Router/vRouter-startup-config-2.txt")}"

  tags {
    Name = "vEOS Router-02"
  }
}

resource "aws_network_interface" "eth-22" {
  subnet_id         = "${aws_subnet.subnet-22.id}"
  source_dest_check = false
  private_ips       = ["10.2.2.8"]
  security_groups   = ["${aws_security_group.sg-alq-02.id}"]

  attachment {
    instance     = "${aws_instance.router-02.id}"
    device_index = 1
  }
}

#resource "aws_network_interface" "eth-23" {
#  subnet_id         = "${aws_subnet.subnet-23.id}"
#  source_dest_check = false
#  private_ips       = ["10.2.3.8"]
#  security_groups   = ["${aws_security_group.sg-alq-02.id}"]
#
#  attachment {
#    instance     = "${aws_instance.router-02.id}"
#    device_index = 2
#  }
#}

# merge S3-State-Bucket
