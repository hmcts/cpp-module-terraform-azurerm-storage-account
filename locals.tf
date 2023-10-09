locals {
  subnet_map = { for id in var.subnet_sa : id => id }
}
