#!/bin/sh
echo 'Creating an entire ACI tenant - just relax and watch the magic!'
sleep 3
ansible-playbook -i myInventory.ini createTenant.yaml
ansible-playbook -i myInventory.ini createVRF.yaml
ansible-playbook -i myInventory.ini createBD.yaml
ansible-playbook -i myInventory.ini createBdSubnet.yaml
ansible-playbook -i myInventory.ini createApEPG.yaml
ansible-playbook -i myInventory.ini associateVmmDomainToEpg.yaml
ansible-playbook -i myInventory.ini createFilter.yaml
ansible-playbook -i myInventory.ini createContract.yaml
ansible-playbook -i myInventory.ini attachContractToEpg.yaml

