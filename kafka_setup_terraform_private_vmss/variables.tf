variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  default     = "test_kafka"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "ARM_SUBSCRIPTION_ID" {
  description = "subscription id"
  type        = string
}