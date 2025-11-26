terraform {
  required_version = ">= 1.5"
  
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "~> 1.92"
    }
  }
}
