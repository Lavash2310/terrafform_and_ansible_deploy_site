resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = var.s3_bucket_name

  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    Name = "tf-state-bucket"
  }
}

resource "aws_s3_bucket_versioning" "tf_state_bucket_versioning" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_bucket_encryption" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state_bucket_public_access" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "tf_state_bucket_policy" {
  bucket = aws_s3_bucket.tf_state_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.tf_state_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.tf_state_bucket_public_access]
}

resource "aws_s3_bucket_ownership_controls" "tf_state_bucket_ownership" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_dynamodb_table" "tf_state_lock_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "tf-state-lock-table"
  }
}

resource "aws_dynamodb_table" "employee_table" {
  name         = var.dynamodb_employee_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "full_name"

  attribute {
    name = "full_name"
    type = "S"
  }

  tags = {
    Name = "employee-table"
  }
}