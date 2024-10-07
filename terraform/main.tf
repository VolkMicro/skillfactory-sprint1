provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.73.0"
    }
  }
}

# Создаем сеть
resource "yandex_vpc_network" "main" {
  name = "main-network"
}

# Создаем подсеть
resource "yandex_vpc_subnet" "main" {
  name           = "main-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.0.0/16"]
}

# Создаем статический IP для Kubernetes Master
resource "yandex_vpc_address" "k8s_master_ip" {
  name = "k8s-master-ip"
  external_ipv4_address {
    zone_id = var.zone  # Зона доступности
  }
}

# Создаем статический IP для Kubernetes App
resource "yandex_vpc_address" "k8s_app_ip" {
  name = "k8s-app-ip"
  external_ipv4_address {
    zone_id = var.zone  # Зона доступности
  }
}

# Создаем статический IP для сервера мониторинга
resource "yandex_vpc_address" "srv_monitoring_ip" {
  name = "srv-monitoring-ip"
  external_ipv4_address {
    zone_id = var.zone  # Зона доступности
  }
}

# Kubernetes Master Node
resource "yandex_compute_instance" "k8s_master" {
  name        = "k8s-master"
  platform_id = "standard-v2"
  zone        = var.zone
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8tvc3529h2cpjvpkr5"  # Актуальный образ Ubuntu
    }
  }
  network_interface {
    subnet_id      = yandex_vpc_subnet.main.id
    nat            = true
    nat_ip_address = yandex_vpc_address.k8s_master_ip.external_ipv4_address[0].address
  }
  metadata = {
    ssh-keys = "${var.user_name}:${file("${var.ssh_public_key_path}")}"
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ${var.user_name}
          sudo: ALL=(ALL) NOPASSWD:ALL
          groups: sudo
          lock-passwd: false
          passwd: ${var.sudo_password}
          home: /home/${var.user_name}
          shell: /bin/bash
          create-home: true
      chpasswd:
        list: |
          ${var.user_name}:${var.sudo_password}
        expire: False
      ssh_pwauth: True
    EOF
  }
}

# Kubernetes App Node
resource "yandex_compute_instance" "k8s_app" {
  name        = "k8s-app"
  platform_id = "standard-v2"
  zone        = var.zone
  resources {
    cores  = 4
    memory = 8
  }
  boot_disk {
    initialize_params {
      image_id = "fd8tvc3529h2cpjvpkr5"  # Актуальный образ Ubuntu
    }
  }
  network_interface {
    subnet_id      = yandex_vpc_subnet.main.id
    nat            = true
    nat_ip_address = yandex_vpc_address.k8s_app_ip.external_ipv4_address[0].address
  }
  metadata = {
    ssh-keys = "${var.user_name}:${file("${var.ssh_public_key_path}")}"
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ${var.user_name}
          sudo: ALL=(ALL) NOPASSWD:ALL
          groups: sudo
          lock-passwd: false
          passwd: ${var.sudo_password}
          home: /home/${var.user_name}
          shell: /bin/bash
          create-home: true
      chpasswd:
        list: |
          ${var.user_name}:${var.sudo_password}
        expire: False
      ssh_pwauth: True
    EOF
  }
}

# Monitoring and Logging Server
resource "yandex_compute_instance" "srv_monitoring" {
  name        = "srv-monitoring"
  platform_id = "standard-v2"
  zone        = var.zone
  resources {
    cores  = 4
    memory = 16
  }
  boot_disk {
    initialize_params {
      image_id = "fd8tvc3529h2cpjvpkr5"  # Актуальный образ Ubuntu
    }
  }
  network_interface {
    subnet_id      = yandex_vpc_subnet.main.id
    nat            = true
    nat_ip_address = yandex_vpc_address.srv_monitoring_ip.external_ipv4_address[0].address
  }
  metadata = {
    ssh-keys = "${var.user_name}:${file("${var.ssh_public_key_path}")}"
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ${var.user_name}
          sudo: ALL=(ALL) NOPASSWD:ALL
          groups: sudo
          lock-passwd: false
          passwd: ${var.sudo_password}
          home: /home/${var.user_name}
          shell: /bin/bash
          create-home: true
      chpasswd:
        list: |
          ${var.user_name}:${var.sudo_password}
        expire: False
      ssh_pwauth: True
    EOF
  }
}
