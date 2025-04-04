mock_provider "aws" {}

run "sets_correct_name" {
  variables {
    bucket_name = "mario21ic-bucket-mock-name"
  }

  assert {
    condition     = aws_s3_bucket.my_bucket.bucket == "mario21ic-bucket-mock-name"
    error_message = "incorrect bucket name"
  }
}

