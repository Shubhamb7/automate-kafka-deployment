resource "aws_s3_bucket" "connect_s3bucket" {
  count = tonumber(var.connect_configuration["connect_count"]) == 0 ? 0 : 1
  bucket = var.connect_configuration["s3bucket_name"]
  force_destroy = true
 
  tags = {
    Name = "${var.connect_configuration["s3bucket_name"]}"
  }
}

resource "aws_s3_bucket_public_access_block" "connect_s3bucket_public_access" {
  count = length(aws_s3_bucket.connect_s3bucket)
  bucket = aws_s3_bucket.connect_s3bucket[0].id
  depends_on = [ aws_s3_bucket.connect_s3bucket ]
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "connect_s3bucket_policy" {
  count = length(aws_s3_bucket.connect_s3bucket)
  bucket = aws_s3_bucket.connect_s3bucket[0].id
  depends_on = [ aws_s3_bucket_public_access_block.connect_s3bucket_public_access ]
  policy = <<EOF
{
   "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowReadWriteAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::${var.connect_configuration["s3bucket_name"]}/*",
                "arn:aws:s3:::${var.connect_configuration["s3bucket_name"]}"
            ]
        }
    ]
}
EOF
}




