variable "environment" { type = string }
variable "aws_region" { type = string }

variable "alb_services" {
  type = map(object({
    port                 = number
    health_check_path    = string
    health_check_matcher = optional(string, "200,404") # Adopts the AWS reality
    health_check_timeout = optional(number, 5)
    interval             = optional(number, 30)
  }))
}