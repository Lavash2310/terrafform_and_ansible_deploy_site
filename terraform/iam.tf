resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name       = "flask_app_s3_access"
  role       = aws_iam_role.s3_access_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.tf_state_bucket.arn,
          "${aws_s3_bucket.tf_state_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "s3_access_instance_profile" {
  name = "s3_access_instance_profile"
  role = aws_iam_role.s3_access_role.name
}