# ansible-templates
Some Ansible templates 

This playbook is installing FreeIPA-client from local hosts file. For another file, like enventory.yml change it in command after **-i** key.
Run by command:
**ansible-playbook -i hosts $CI_PROJECT_DIR/universal_ipa-client_install --extra-vars "ROOT_PASS=$ROOT_PASS"**

Bash script creating user **ansible** and disabling **SELinux** for normal ssh working.
