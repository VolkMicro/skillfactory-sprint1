#!/bin/bash

# Путь к Terraform проекту
TERRAFORM_DIR="/mnt/c/diplom/devops/terraform"

# Путь к Ansible плейбуку
ANSIBLE_PLAYBOOK="/mnt/c/diplom/devops/Ansible/1_deploy_k8s_cluster.yml"
ANSIBLE_INVENTORY="/mnt/c/diplom/devops/Ansible/inventory.ini"

# Выполняем terraform taint для пометки ресурсов на пересоздание
cd "$TERRAFORM_DIR"
echo "Tainting existing resources..."

# Замените <resource_name> на точные имена ресурсов
terraform taint yandex_compute_instance.k8s_master
terraform taint yandex_compute_instance.k8s_app
terraform taint yandex_compute_instance.srv_monitoring

if [ $? -ne 0 ]; then
  echo "Terraform taint failed. Exiting..."
  exit 1
fi

# Выполняем terraform apply для пересоздания ресурсов
echo "Running Terraform apply..."
terraform apply -auto-approve

if [ $? -ne 0 ]; then
  echo "Terraform apply failed. Exiting..."
  exit 1
fi

# Функция для отображения прогресс-бара
show_progress() {
    echo -n "Waiting for hosts to become available"
    while ! ansible all -i "$ANSIBLE_INVENTORY" -m ping &> /dev/null; do
        echo -n "."
        sleep 5
    done
    echo " All hosts are now available!"
}

# Ожидание доступности всех хостов
show_progress

# Переходим к Ansible playbook и выполняем его
echo "Running Ansible playbook..."
cd -
ansible-playbook -i "$ANSIBLE_INVENTORY" "$ANSIBLE_PLAYBOOK"

if [ $? -ne 0 ]; then
  echo "Ansible playbook failed. Exiting..."
  exit 1
fi

echo "Deployment completed successfully."
