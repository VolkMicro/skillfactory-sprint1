output "k8s_master_ip" {
  value = yandex_compute_instance.k8s_master.network_interface[0].nat_ip_address
}

output "k8s_app_ip" {
  value = yandex_compute_instance.k8s_app.network_interface[0].nat_ip_address
}

output "srv_monitoring_ip" {
  value = yandex_compute_instance.srv_monitoring.network_interface[0].nat_ip_address
}
