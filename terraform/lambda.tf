# there is a bit of a dependency issue here. The source coude needs to
# exist so this code runs.
# the prefered solution is to comment out the below code on the first
# deployment

data "aws_s3_bucket_object" "source_code_key" {
  bucket = aws_s3_bucket.poc_lambdas.id
  key    = "poc_report/stable.zip"

  depends_on = [
    aws_s3_bucket.poc_lambdas,
  ]
}

resource "aws_lambda_function" "poc_lambda_function" {
  s3_bucket     = aws_s3_bucket.poc_lambdas.id
  s3_key        = "poc_report/stable.zip"
  function_name = "poc_lambda_function"
  role          = aws_iam_role.poc_role.arn
  handler       = "main.lambda_handler"

  source_code_hash = data.aws_s3_bucket_object.source_code_key.etag

  runtime = "python3.8"

  environment {
    variables = {
      "S3_BUCKET_TARGET" = aws_s3_bucket.poc_target.id
    }
  }
}

resource "aws_s3_bucket_notification" "poc_bucket_notification" {
  bucket = aws_s3_bucket.poc_source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.poc_lambda_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.poc_allow_bucket]
}

resource "aws_lambda_permission" "poc_allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.poc_lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.poc_source.arn
}
