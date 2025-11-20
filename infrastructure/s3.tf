resource "aws_s3_bucket" "example" {
    bucket = "mybucket1906wojtek"
}

resource "aws_s3_bucket_acl" "example" {
    bucket = aws_s3_bucket.example.id
    acl    = "private"
}