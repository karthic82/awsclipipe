provider "aws" {
  region  = var.region
}


  module "log-management" {
    source = "./modules/log-management"
}

    
