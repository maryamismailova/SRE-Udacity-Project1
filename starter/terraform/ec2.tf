#  module "project_ec2" {
#    source             = "./modules/ec2"
#    name               = local.name
#    account            = data.aws_caller_identity.current.account_id
#    aws_ami            = data.aws_ami.amazon_linux_2.id
#    private_subnet_ids = module.vpc.private_subnet_ids
#    vpc_id             = module.vpc.vpc_id
#  }

  module "project_ec2" {
   source             = "./modules/ec2"
   name               = local.name
   account            = data.aws_caller_identity.current.account_id
   aws_ami            = "ami-0d759bfbb49762076"
   private_subnet_ids = module.vpc.private_subnet_ids
   public_subnet_ids = module.vpc.public_subnet_ids
   vpc_id             = module.vpc.vpc_id
   ec2_key_name       = aws_key_pair.deployer.key_name

 }

 resource "aws_key_pair" "deployer" {
  key_name   = "admin"
  public_key = var.key_pair_pub
}

variable "key_pair_pub" {
  default = ""
}

variable "key_pair_private_path" {
  default = ""
}

variable "ansible_inventory_dir" {
  default = "/mnt/d/dev/SRE/Lesson1/Project/cd1898-Observing-Cloud-Resources/starter/node_exporter/inventory"
}

resource "null_resource" "update_host" {

  provisioner "local-exec" {
    working_dir = var.ansible_inventory_dir
    command = "sed -i.`date +\"%Y-%m-%d-%H-%M\"` \"s/\\(ansible_host=\\)\\(\\S*\\)/\\1${module.project_ec2.ec2_instance_pub_ip}/g\" hosts"
  }
}

resource "null_resource" "launch_ansible" {

  # triggers  = [
  #   null_resource.update_host.id
  # ]
  provisioner "local-exec" {
    working_dir = "${var.ansible_inventory_dir}/.."
    command = "ansible-playbook -i inventory/hosts playbook.yml --key-file ${var.key_pair_private_path}"
  }

  depends_on = [
    null_resource.update_host,
  ]
}