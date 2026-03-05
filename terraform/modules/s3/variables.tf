variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "lifecycle_days" {
  description = "Days before moving objects to Glacier"
  type        = number
  default     = 90
}