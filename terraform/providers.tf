# versions.tf — create this new file at root
terraform {
  required_version = ">= 1.9.0"  # Add this line
  
required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # your region
}
