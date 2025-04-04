terraform {
  backend "s3" {
    bucket         = "mejuri-s3-bucket"   
    key            = "terraform/state/terraform.tfstate"   # Path inside the bucket to store the state
    region         = "us-east-1"
    encrypt        = true 
    dynamodb_table = "mejuri-state-lock"   
    use_lockfile  = true
    acl            = "bucket-owner-full-control"
  }
}
