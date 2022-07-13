# Cloud Trail Logs

data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "ht_s3_bucket" {
  name                          = "HT-Cloud_Trail"
  s3_bucket_name                = aws_s3_bucket.ht_buckt.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
  s3_key_prefix                 = "prefix"
  include_global_service_events = false

   event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

}

resource "aws_s3_bucket" "ht_buckt" {
  bucket        = var.s3_bucketname
  force_destroy = true
}

resource "aws_s3_bucket_policy" "ht_buckt" {
  bucket = aws_s3_bucket.ht_buckt.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.ht_buckt.arn}",
            "Condition": {
                "StringEquals": {
                    "aws:SourceArn": "${aws_cloudtrail.ht_s3_bucket.arn}"
                }
            }
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.ht_buckt.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control",
                    "aws:SourceArn": "${aws_cloudtrail.ht_s3_bucket.arn}"
                }
            }
        }
    ]
}
POLICY
}

