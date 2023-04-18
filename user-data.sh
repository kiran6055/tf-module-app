#!/bin/bash

labauto ansible
ansible-pull -i loaclhost, -U https://github.com/kirankumar7163/ansible-roboshop roboshop.yml -e ROLE_NAME=${component} -e env=${env} | tee /opt/ansible.log