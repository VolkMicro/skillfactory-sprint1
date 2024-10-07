# Развертывание инфраструктуры Kubernetes кластера и сервера мониторинга

## Описание проекта

Данный проект предназначен для автоматического развертывания инфраструктуры, состоящей из Kubernetes кластера (1 мастер-нода и 1 воркер-нода) и отдельного сервера `srv` для инструментов мониторинга, логирования и сборки контейнеров.

Инфраструктура описана с помощью Terraform, а автоматизация установки и настройки необходимых пакетов реализована с использованием Ansible. Это обеспечивает быстрый и повторяемый процесс развертывания, минимизируя количество ручных действий.

## структура репозитория

│   deploy.sh
│   README.md

├───Ansible

│       1_deploy_k8s_cluster.yml
│       inventory.ini
│       join_workers.yml
│

└───terraform
    │   .terraform.lock.hcl
    
    │   main.tf  
    │   outputs.tf    
    │   terraform.tfstate    
    │   terraform.tfstate.backup
    │   terraform.tfvars
    │   variables.tf
    │
    └───.terraform
        └───providers
            └───registry.terraform.io
                └───yandex-cloud
                    └───yandex
                        └───0.73.0
                            ├───linux_amd64
                            │       CHANGELOG.md
                            │       LICENSE
                            │       README.md
                            │       terraform-provider-yandex_v0.73.0
                            │
                            └───windows_amd64
                                    CHANGELOG.md
                                    LICENSE
                                    README.md
                                    terraform-provider-yandex_v0.73.0.exe



## Требования

- **Terraform** версии **0.12** или выше
- **Ansible** версии **2.9** или выше
- **SSH-ключи** для доступа к серверам
- Учетная запись в облачном провайдере (например, **Яндекс.Облако**)
- **bash** для выполнения скриптов (или WSL на Windows)

## Шаги по развертыванию

### 1. Клонирование репозитория

Склонируйте репозиторий на локальную машину:

git clone https://github.com/VolkMicro/skillfactory-sprint1.git
cd skillfactory-sprint1

## Terraform для создания инфраструктуры
Перейдите в директорию terraform/:

Инициализируйте Terraform
terraform init

Создайте файл terraform.tfvars и заполните его вашими значениями:

yandex_token    = ""

cloud_id        = ""

folder_id       = ""

ssh_public_key_path = ""

user_name       = ""

sudo_password   = ""

Запуск Terraform для создания инфраструктуры

terraform apply


## Настройка Ansible
Отредактируйте файл Ansible/inventory.ini, заменив плейсхолдеры на реальные IP-адреса созданных серверов и вашего пользователя:
[master]
Ваш внешний айпи ansible_user=microvolk

[workers]
Ваш внешний айпи ansible_user=microvolk

[srv_monitoring]
Ваш внешний айпиansible_user=microvolk

[all:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'


## Запуск автоматической настройки инфраструктуры
./deploy.sh

## Доступ к инструментам мониторинга
На сервере srv установлены и запущены сервисы мониторинга:

Grafana доступна по адресу: http://IP_SRV:3000
Prometheus доступен по адресу: http://IP_SRV:9090

##Ручные действия

Настройка Grafana: После установки вы можете войти в Grafana (по умолчанию логин и пароль: admin/admin) и настроить источники данных, дашборды и алерты.
Настройка алертинга в Grafana: Для получения уведомлений необходимо настроить контактные точки и политики уведомлений (например, интеграцию с Telegram).



#Дополнительная информация

Получение cloud_id и folder_id в Яндекс.Облаке
Получение cloud_id:

Войдите в Яндекс.Облако
Перейдите в раздел Облака
Выберите нужное облако
В URL будет указан cloudId, например: https://console.cloud.yandex.ru/folders/<folderId>?cloudId=<cloudId>

##Получение folder_id:

Перейдите в раздел Каталоги
Выберите нужный каталог
В URL будет указан folderId

##Получение OAuth-токена
Перейдите на страницу Управление доступом
Создайте новый токен с нужными правами доступа
Используйте полученный токен в terraform.tfvars

##Замечания
Безопасность: Не храните секреты и приватные ключи в системе контроля версий.
Расширяемость: Вы можете изменить количество воркер-нод, отредактировав Terraform конфигурации и Ansible инвентори файл.
Совместимость: Убедитесь, что используете совместимые версии Terraform, Ansible и Kubernetes.
