locals {
  prefix = "patrick-cloud"
  tags = {
    env        = var.env
    project    = "patrick-cloud"
    deployment = "terraform"
    repo       = "https://github.com/patrickoconnor80/patrick-cloud-kubernetes/tree/main/tf/volumes"
  }
}