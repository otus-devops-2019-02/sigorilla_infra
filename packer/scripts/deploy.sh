#!/bin/bash

# Install application
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install

# Setup service
mv /tmp/puma.service /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl enable puma
