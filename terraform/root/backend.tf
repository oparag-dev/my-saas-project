terraform {
  backend "s3" {
    bucket       = "opara-saas-terraform-state"
    key          = "saas-project/dev/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}