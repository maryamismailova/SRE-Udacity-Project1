output "ec2_instance_pub_ip" {
    value = aws_instance.web.public_ip
}