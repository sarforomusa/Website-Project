variable "aws_region" {
  default = "eu-west-2"
}


variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "VPC cidr Block"
  type        = string
  
}


variable "subnet_count" {
  description = "4 subnets"
  type        = map(number)
  default = {
    "web-public-subnets"  = 2,
    "app-private-subnets" = 2
  }
}

variable "web-public-subnets" {
  description = "cidr blocks for web public subnets"
  type        = list(string)
  default = ["10.0.10.0/24","10.0.11.0/24","10.0.14.0/24","10.0.16.0/24"]

}

variable "app-private-subnets" {
  description = "cidr blocks for app private subnets"
  type        = list(string)
  default = ["10.0.12.0/24","10.0.13.0/24","10.0.17.0/24","10.0.18.0/24"]

}

variable "my_ip" {
  description = "ip address"
  type        = string
  sensitive   = true

}

variable "db_username" {
  description = "databes master user"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "database master password"
  type        = string
  sensitive   = true

}
variable "settings" {
  description = "configuration settings"
  type        = map(any)
  default = {
    "database" = {
      allocated_storage   = 10
      engine              = "mysql"
      engine_version      = "8.0.32"
      instance_class      = "db.t2.micro"
      db_name             = "mydatabase"
      skip_final_snapshot = "true"
    },
    "web_app" = {
      count         = "1"
      instance_type = "t2.micro"
    }

  }
}


