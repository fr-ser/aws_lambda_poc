data "aws_iam_policy_document" "poc_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "poc_logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "poc_source_read" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:HeadObject",
    ]

    resources = [
      "arn:aws:s3:::lambda-poc-unique-name-source/*"
    ]
  }
}

data "aws_iam_policy_document" "poc_target_read_write" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::lambda-poc-unique-name-target/*"
    ]
  }
}

resource "aws_iam_role" "poc_role" {
  name               = "poc_iam_assume_role"
  assume_role_policy = data.aws_iam_policy_document.poc_assume_role.json
}

resource "aws_iam_role_policy" "poc_attach_logging" {
  name   = "poc_attach_logging"
  role   = aws_iam_role.poc_role.id
  policy = data.aws_iam_policy_document.poc_logging.json
}

resource "aws_iam_role_policy" "poc_attach_source_read" {
  name   = "poc_attach_source_read"
  role   = aws_iam_role.poc_role.id
  policy = data.aws_iam_policy_document.poc_source_read.json
}

resource "aws_iam_role_policy" "poc_attach_target_read_write" {
  name   = "poc_attach_target_read_write"
  role   = aws_iam_role.poc_role.id
  policy = data.aws_iam_policy_document.poc_target_read_write.json
}
