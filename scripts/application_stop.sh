#!/bin/bash

sudo systemctl stop ka_gunicorn.service || exit 1
sudo systemctl stop od_gunicorn.service || exit 1
# sudo systemctl stop jk.service || exit 1
