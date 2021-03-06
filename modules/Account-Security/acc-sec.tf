# Bucket Creation to store CFT YAML source code

resource "aws_s3_bucket" "hitech_buck" {
  bucket = "hitech-account-security"
  acl    = "public-read-write"
}


# Adding CFT YAML source code into Above created S3 Bucket

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.hitech_buck.id
  acl    = "public-read-write"
  key    = "security.yml"
  source = "/var/lib/jenkins/workspace/Karthic_Jenkins_Pipeline/modules/Account-Security/CFT/security.yml"

}


# CLOUDFORMATION CREATION 

resource "aws_cloudformation_stack" "acc-security" {
  depends_on = [aws_s3_bucket_object.object]
  name = "CFT-ACC-SECURITY"
  disable_rollback = true
  template_url = "https://${aws_s3_bucket.hitech_buck.id}.s3.amazonaws.com/security.yml"
}
