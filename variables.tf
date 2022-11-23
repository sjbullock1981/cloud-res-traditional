variable "profile" {
  type    = string
  default = "default"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default     = ["us-east-1a", "us-east-1b"]
  type        = list(any)
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidrs_web" {
  description = "Subnet CIDRs for public web subnets"
  default     = ["10.0.64.0/19", "10.0.96.0/19"]
  type        = list(any)
}

variable "subnet_cidrs_db" {
  description = "Subnet CIDRs for private database subnets"
  default     = ["10.0.128.0/19", "10.0.160.0/19"]
  type        = list(any)
}

variable "instance_count" {
  description = "Number of web instances to be deployed"
  type        = number
  default     = 2

}

variable "webserver-port" {
  type    = number
  default = 80
}

variable "http_port" {
  type    = number
  default = 8080
}

variable "https_port" {
  type    = number
  default = 443
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "postgresql_port" {
  type    = number
  default = 443
}

variable "dns-name" {
  type    = string
  default = "sambullock-cv-website.co.uk."
}