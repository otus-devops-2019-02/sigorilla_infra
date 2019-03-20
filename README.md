# sigorilla_infra

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

```conf
bastion_IP = 35.207.175.188
someinternalhost_IP = 10.156.0.3

```

По HTTPS сервис доступен по следующему урлу: https://35.207.175.188.xip.io
