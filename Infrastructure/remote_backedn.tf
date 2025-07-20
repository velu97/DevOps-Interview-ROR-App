terraform {
  backend "s3" {
    bucket         = "devops-interview-tfstate"  
    key            = "eks-cluster/terraform.tfstate"
    region         = "ap-south-1"              
    encrypt        = true
    dynamodb_table = "devops-interview-tfstate-lock"
  }
}
