variable "database_user" {
  description = "The database username"
  type        = string
  sensitive = true
}

variable "database_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "The base name for the database"
  type        = string
  sensitive = true
}
