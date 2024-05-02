variable "environment" {
  type = object({
    type   = string
    prefix = string
  })
  description = "Cloud environment config."
}

variable "location" {
  type        = string
  description = "The name of the location this repository is located in."
}