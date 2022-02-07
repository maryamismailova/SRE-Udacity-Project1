#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory/hosts playbook.yml --key-file /mnt/d/dev/SRE/Lesson1/Project/tokens/udacity