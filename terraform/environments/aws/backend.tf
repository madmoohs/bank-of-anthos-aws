terraform {

  backend "s3" {

    bucket = "muhsinntu-bankofanthos-tfstate-255945442255-2fea81"

    key = "aws/dev/terraform.tfstate"

    region = "ap-southeast-1"

    dynamodb_table = "muhsinntu-bankofanthos-terraform-locks"

    encrypt = true

  }

}