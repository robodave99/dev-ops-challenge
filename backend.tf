terraform {
  backend "s3" {
    bucket         = "mejuri-s3-bucket"   
    key            = "terraform/state/terraform.tfstate"   # Path inside the bucket to store the state
    region         = "us-east-1"
    encrypt        = true    
    use_lockfile  = "mejuri-state-lock" 
    acl            = "bucket-owner-full-control"
  }
}
