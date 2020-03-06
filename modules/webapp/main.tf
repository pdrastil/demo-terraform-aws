# Packer builder for Golden AMI
resource "null_resource" "packer" {
  triggers = {
    app_version = var.app_version
    json_sha    = filesha256("aws_ami.json")
  }

  provisioner "local-exec" {
    command = <<EOD
packer build \
  -var version=${var.app_version} \
  -var aws_region=${var.region} \
  -var vpc_id=${var.vpc_id} \
  aws_ami.json
EOD
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOD
AMI_ID=$(
  aws ec2 describe-images \
    --owners "self" \
    --filters "Name=name,Values=demo" \
    --query "sort_by(Images, &CreationDate)[-1].[ImageId]" \
    --output "text"
)

aws ec2 deregister-image --image-id $AMI_ID
EOD
  }
}
