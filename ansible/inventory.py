#!/usr/bin/python

import os
import yaml
import json
from argparse import ArgumentParser

def get_ip(name):
    config = os.popen("gcloud compute instances describe {0}".format(name)).read()
    return yaml.safe_load(config)['networkInterfaces'][0]['accessConfigs'][0]['natIP']

def add_server(result, name, ip):
    server = '{0}server'.format(name)
    result['_meta']['hostvars'][server] = {
        'ansible_host': ip
    }
    result[name] = {
        'hosts': [server]
    }

def main():
    parser = ArgumentParser(description='Ansible inventory')
    parser.add_argument('--list', action='store_true')
    args = parser.parse_args()

    result = {}

    if args.list:
        result['_meta'] = {
            'hostvars': {}
        }

        add_server(result, 'app', get_ip('reddit-app-0'))
        add_server(result, 'db', get_ip('reddit-db'))


    print(json.dumps(result))

if __name__ == "__main__":
    main()
