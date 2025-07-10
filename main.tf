terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider in the us-east-1 region
provider "aws" {
  region = "us-east-1"
}

################################################################################
# S3 BUCKET FOR WEBSITE
################################################################################

# Create an S3 bucket for the website files
resource "aws_s3_bucket" "website_bucket" {
  bucket = "mjaved-resume-website-2025-v2" # Renamed

  tags = {
    Name        = "My Resume Website Bucket"
    Project     = "Serverless Resume"
  }
}

# Configure the S3 bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# Upload website files to the S3 bucket
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "index.html"
  source = "index.html" 
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "style.css"
  source = "style.css"
  content_type = "text/css"
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "script.js"
  source = "script.js"
  content_type = "application/javascript"
}

################################################################################
# CLOUDFRONT DISTRIBUTION
################################################################################

# Create an Origin Access Control for CloudFront
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "OAC for mjaved-resume-website-v2" # Renamed
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Create a CloudFront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "S3-${aws_s3_bucket.website_bucket.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website_bucket.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Create a bucket policy that allows CloudFront to access the S3 bucket
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

################################################################################
# DYNAMODB TABLE
################################################################################

# Create a DynamoDB table to store the visitor count
resource "aws_dynamodb_table" "visitor_table" {
  name           = "visitor-counter-v2" # Renamed
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"

  attribute {
    name = "PK"
    type = "S"
  }
}

################################################################################
# IAM ROLE FOR LAMBDA
################################################################################

# IAM policy document that allows Lambda to assume this role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# IAM policy document for Lambda execution permissions
data "aws_iam_policy_document" "lambda_exec_policy" {
  # Allow logging to CloudWatch
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
  # Allow reading/writing to the DynamoDB table
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.visitor_table.arn]
  }
}

# Create the IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name               = "resume-visitor-counter-role-v2" # Renamed
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# Attach the execution policy to the IAM role
resource "aws_iam_role_policy" "lambda_exec_policy" {
  name   = "DynamoDBVisitorCounterPolicyV2"
  role   = aws_iam_role.lambda_exec_role.id
  policy = data.aws_iam_policy_document.lambda_exec_policy.json
}

################################################################################
# LAMBDA FUNCTION
################################################################################

# Zip up the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Create the Lambda function
resource "aws_lambda_function" "visitor_counter_lambda" {
  function_name    = "updateVisitorCounterV2" # Renamed
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_exec_role.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

################################################################################
# API GATEWAY
################################################################################

# Create an HTTP API Gateway
resource "aws_apigatewayv2_api" "visitor_api" {
  name          = "visitor-counter-api-v2" # Renamed
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"] 
    allow_methods = ["POST"]
    allow_headers = ["Content-Type"]
  }
}

# Create the integration between API Gateway and the Lambda function
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.visitor_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.visitor_counter_lambda.invoke_arn
}

# Create the route for POST /visit
resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.visitor_api.id
  route_key = "POST /visit"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Create the default stage and turn on auto-deployment
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.visitor_api.id
  name        = "$default"
  auto_deploy = true
}

# Add permission for API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.visitor_api.execution_arn}/*/*"
}

################################################################################
# OUTPUTS
################################################################################

# Output the CloudFront domain name so you can easily access it
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

# Output the API Gateway invoke URL
output "api_invoke_url" {
  value = aws_apigatewayv2_api.visitor_api.api_endpoint
}
