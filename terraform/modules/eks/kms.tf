resource "aws_kms_key" "eks" {

  description = "${var.project_name} EKS Secret Encryption"

  deletion_window_in_days = 7

  enable_key_rotation = true

}