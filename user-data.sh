#!/bin/bash

labauto
ansible-pull -i loaclhost, -U https://github.com/ansible-roboshop roboshop.yml -e ROLE_NAME=${component} -e env=${env} | tee /pot/ansible.log