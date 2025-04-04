variables {
  bucket_prefix = "mario21ic"
}

run "valid_s3_bucket_name" {

  command = apply

  assert {
    condition     = module.s3_bucket.s3_bucket_id == "test123-mys3-alb-logs"
    error_message = "S3 bucket name did not match expected"
  }
}
