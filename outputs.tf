#
# Server VPC-01
#
output "public_ip server-12" {
  value = "${aws_instance.server-12.public_ip}"
}

output "private_ip server-12 eth0" {
  value = "${aws_instance.server-12.private_ip}"
}

#output "public_ip server-13" {
#  value = "${aws_instance.server-13.public_ip}"
#}

#output "private_ip server-13 eth0" {
#  value = "${aws_instance.server-13.private_ip}"
#}

#
#
#
output "public_ip server-22" {
  value = "${aws_instance.server-22.public_ip}"
}

output "private_ip server-22 eth0" {
  value = "${aws_instance.server-22.private_ip}"
}

#output "public_ip server-23" {
#  value = "${aws_instance.server-23.public_ip}"
#}

#output "private_ip server-23 eth0" {
#  value = "${aws_instance.server-23.private_ip}"
#}

#
#
#
output "public_ip router-01" {
  value = "${aws_instance.router-01.public_ip}"
}

output "private_ip router-01" {
  value = "${aws_instance.router-01.private_ip}"
}

#
#
#
output "public_ip router-02" {
  value = "${aws_instance.router-02.public_ip}"
}

output "private_ip router-02" {
  value = "${aws_instance.router-02.private_ip}"
}

#output "ENI-primary-01" {
#  value = "${aws_instance.router-01.primary_network_interface_id}"
#}

#output "ENI-primary-02" {
#  value = "${aws_instance.router-01.primary_network_interface_id}"
#}

# output "vEOS Router IF 1" {
#   value = "${aws_network_interface.eth-0.id}"
# }

#output "vEOS Router-01 IF 2" {
#  value = "${aws_network_interface.eth-12.id}"
#}

#output "vEOS Router-01 IF 3" {
#  value = "${aws_network_interface.eth-13.id}"
#}

#
#
#

#output "vEOS Router-02 IF 2" {
#  value = "${aws_network_interface.eth-22.id}"
#}

#output "vEOS Router-02 IF 3" {
#  value = "${aws_network_interface.eth-23.id}"
#}

#output "Jump-Host-01" {
#  value = "${aws_instance.JH-01.public_ip}"
#}

#output "Jump-Host-02" {
#  value = "${aws_instance.JH-02.public_ip}"
#}
