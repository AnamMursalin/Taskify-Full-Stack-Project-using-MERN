variable "project_name" {
  description = "The base name for all resources"
  type        = string
  default     = "taskify-mern"
}

variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
  default     = "southeastasia"
}

variable "mongodb_uri" {
  description = "The MongoDB connection string"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "The JWT secret for signing tokens"
  type        = string
  sensitive   = true
}
