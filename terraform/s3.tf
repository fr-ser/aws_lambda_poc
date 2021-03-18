resource "aws_s3_bucket" "poc_source" {
  bucket = "lambda-poc-unique-name-source"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "poc_target" {
  bucket = "lambda-poc-unique-name-target"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# this bucket contains the lambda source code 
resource "aws_s3_bucket" "poc_lambdas" {
  bucket = "lambda-poc-unique-name-lambda-source"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
