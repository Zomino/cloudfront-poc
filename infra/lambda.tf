data "archive_file" "lambda_zip" {
  output_path = format("%s/../build/lambda.zip", path.module)
  type        = "zip"
  source_file = format("%s/../src/lambda.mjs", path.module)
}

resource "aws_lambda_function" "cloudfront_poc" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "cloudfront_poc"
  handler          = "lambda.handler"
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10
}

resource "aws_iam_role" "lambda_exec" {
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
  name               = "cloudfront_poc_lambda_exec_role"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_exec_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_exec.name
}