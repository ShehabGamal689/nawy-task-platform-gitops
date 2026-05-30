terraform {
  required_version = ">= 1.0"
  
    backend "s3" {
    bucket  = "nawy-task"
    key     = "eks/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13" 
    }
     kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0" 
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
   }
  }
}



