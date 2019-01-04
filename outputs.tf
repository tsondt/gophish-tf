output "image_id" {
  value = "${data.aws_ami.ubuntu.id}"
}

output "public_ipv4" {
  value = "${aws_instance.gophish.public_ip}"
}
