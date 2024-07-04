terraform{ // configure metadata and info of terraform
   required_version = ">= 0.12"
   backend "s3" {
     bucket = "" // create the bucket first 
     key = "" // state file path
     region = ""
   }
}
