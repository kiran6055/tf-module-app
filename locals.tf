locals {
  common_tags = {
    env = var.env
    project = "roboshop"
    business_unit = "ecommerce"
    owner = "IBM-ecommerce"

  }
  all_tags = [
    { key = "env", value = var.env },
    { key = "project", value = "roboshop" },
    { key = "business_unit", value = "ecommerce" },
    { key = "owner", value = "IBM-ecommerce" },
    { key = "name", value = "${var.env}-${var.component}" },
  ]
}