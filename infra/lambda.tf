data "archive_file" "cf_poc_lambda_zip" {
  output_path = format("%s/../build/lambda.zip", path.module)
  type        = "zip"
  source_file = format("%s/../src/lambda.mjs", path.module)
}

resource "aws_lambda_function" "cf_poc" {
  function_name    = "cf-poc"
  filename         = data.archive_file.cf_poc_lambda_zip.output_path
  handler          = "lambda.handler"
  runtime          = "nodejs22.x"
  role             = aws_iam_role.cf_poc_lambda.arn
  source_code_hash = data.archive_file.cf_poc_lambda_zip.output_base64sha256
  timeout          = 10
}

resource "aws_iam_role" "cf_poc_lambda" {
  name               = "cf-poc-lambda"
  assume_role_policy = data.aws_iam_policy_document.cf_poc_lambda_assume.json
}

data "aws_iam_policy_document" "cf_poc_lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "cf_poc_lambda" {
  role       = aws_iam_role.cf_poc_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "cf_poc_lambda_allow_alb" {
  function_name = aws_lambda_function.cf_poc.function_name
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.cf_poc_lambda.arn
}