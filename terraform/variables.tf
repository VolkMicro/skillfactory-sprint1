variable "yandex_token" {
  description = "OAuth token for Yandex.Cloud"
}

variable "cloud_id" {
  description = "ID of the Yandex Cloud"
}

variable "folder_id" {
  description = "ID of the Yandex Cloud folder"
}

variable "zone" {
  description = "Yandex.Cloud zone"
  default     = "ru-central1-a"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
}

variable "user_name" {
  description = "SSH username"
  default     = "microvolk"  # Логин пользователя
}

variable "sudo_password" {
  description = "Password for sudo"
  sensitive   = true  # Отмечаем как чувствительную переменную
}
