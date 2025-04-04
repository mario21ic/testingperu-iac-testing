variables {
  bucket_name = "mario21ic-test"
}

run "unit_valid_bucket_name" {
  command = plan

  assert {
    condition     = aws_s3_bucket.my_bucket.bucket == "mario21ic-test"
    error_message = "S3 bucket name did not match expected"
  }
}
