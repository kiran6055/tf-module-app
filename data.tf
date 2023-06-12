data "aws_kms_key" "key" {
  key_id = "alias/roboshop"
}

data "aws_ami" "centos8" {
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
  owners      = ["973714476881"]
}
# owners and name of regex is I created a custom ami image with ansible installed in instance so I have given that owner number and name of regex
#086083061026/ansibleinstalled which we will get from source in ami image