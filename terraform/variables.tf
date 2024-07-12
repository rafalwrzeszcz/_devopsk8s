variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type    = list(string)
}
