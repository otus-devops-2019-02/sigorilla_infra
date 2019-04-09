# sigorilla_infra

```conf
bastion_IP = 35.207.175.188
someinternalhost_IP = 10.156.0.3

testapp_IP = 35.197.197.52
testapp_port = 9292
```

## Подключение к `someinternalhost`

```bash
ssh -Ao ProxyCommand="ssh -W %h:%p 35.207.175.188" 10.156.0.3
```

### Одной командой

Вставте в `~/.ssh/config` следующую конфигурацию:

```conf
Host bastion
    Hostname 35.207.175.188
    IdentityFile ~/.ssh/id_rsa
    ForwardAgent yes

Host someinternalhost
    Hostname 10.156.0.3
    ProxyCommand ssh -W %h:%p bastion
    IdentityFile ~/.ssh/id_rsa
    ForwardAgent yes
```

И выполните:

```bash
ssh someinternalhost
```

По HTTPS сервис доступен по следующему урлу: https://35.207.175.188.xip.io

## Настройка gcloud

Создание инстанса:

```sh
gcloud compute instances create reddit-app \
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --restart-on-failure \
    --metadata-from-file startup-script=./config-scripts/startup_script.sh
```

Создание инстанса с использование `startup-script-url`:

```sh

gcloud compute instances create reddit-app \
    --boot-disk-size=10GB \
    --image-family ubuntu-1604-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=g1-small \
    --tags puma-server \
    --restart-on-failure \
    --metadata startup-script-url=https://gist.githubusercontent.com/sigorilla/a10ba37df3f27082240d88a270130c7c/raw/b96823fb28e5b6252edf84e4c293ecd1b8be9d28/startup_script.sh
```

Создание правила в файрволе:

```sh
gcloud compute firewall-rules create default-puma-server \
    --allow=tcp:9292 \
    --target-tags=puma-server
```

## Packer

Скопируйте файл `packer/variables.json.example` в `packer/variables.json` и поменяйте значения переменных.

Проверяем шаблон:

```sh
cd packer
packer validate -var-file=./variables.json ubuntu16.json
```

Собираем образ:

```sh
packer build -var-file=./variables.json ubuntu16.json
```

Образ с приложением располагается в `packer/immutable.json`:

```sh
cd packer
packer build -var-file=./variables.json immutable.json
cd -
./config-scripts/create-reddit-vm.sh
```

## Terraform

Используем директорию `./terraform`.

Скопируйте файл `terraform.tfvars.example` в `terraform.tfvars` и поменяйте значение переменных.

Проверяем изменения:

```sh
terraform plan
```

Применяем изменения:

```sh
terraform apply
```

### Изменение существующих значений

Если в веб-интерфейсе добавить какие-то метаданные, например, ssh ключ для пользователя `appuser_web`, то после команды `terraform apply` эти значения будут заменены на значения в конфиге.

Пример добавления ключей в метаданные:

```tf
resource "google_compute_project_metadata" "ssh_keys" {
  metadata {
    ssh-keys = "appuser1:${file(var.public_key_path)}\nappuser2:${file(var.public_key_path)}"
  }
}
```

### Дублирование инстансов

Если каждый инстанс запускать в виде отдельного `google_compute_instance`, то будет много дублирования кода. Вместо этого стоит использовать `count`.


### Изменение стандартного пользователя

В файле переменных можно указать пользователя, из под которого будет запускаться сервис.

Для этого используется провайдер [template](https://www.terraform.io/docs/providers/template/index.html).

### Импорт существующей инфраструктуры

```sh
terraform import google_compute_firewall.firewall_ssh default-allow-ssh
```

### Модули

Модули располагаются в отдельной директории `terraform/modules`, который подключаются в каждую из конфигураций: `prod` и `stage`.

При этом в каждом модуле можно определить необходимый набор переменных.
