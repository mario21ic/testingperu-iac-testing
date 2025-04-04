variables {
  bucket_name = "mario21ic-bucket"
}

run "valid_string_concat" {
  command = apply

  assert {
    condition     = aws_s3_bucket.my_bucket.bucket == "mario21ic-bucket"
    error_message = "S3 bucket name did not match expected"
  }
}
