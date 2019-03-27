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

Образ с приложением распологается в `packer/immutable.json`.
