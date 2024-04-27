variable "location" {
  type        = string
  description = "The name of the location this storage bucket is located in."
}

variable "environment" {
  type = object({
    type   = string
    prefix = string
  })
  description = "Cloud environment config."
}

variable "bucket_name" {
  type        = string
  description = "The name of the storage bucket."
}

variable "object_admin_sa_email" {
  type        = string
  description = "Service account to be assigned storage bucket object admin role."
}
