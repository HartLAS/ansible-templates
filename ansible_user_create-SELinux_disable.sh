#!/bin/bash
#Text formatter
prn_txt (){
local part2 style delim indent
case $1 in
	1) delim=" : "; indent=" ";;
	2) delim=" --> "; indent="     ";; 
	3) delim=" ----> "; indent="           ";;
esac
case $# in
	2)
		echo -e "$indent$2"
	;;
	3|4)
		style=${4:-NO_STYLE}
		case $style in
			red)
				echo -e "$indent$2$delim\e[1;31m$3\e[0m"
			;;
			green)
				echo -e "$indent$2$delim\e[32m$3\e[0m"
			;;	
			cyan)
				echo -e "$indent$2$delim\e[36m$3\e[0m"
			;;
			blue)
				echo -e "$indent$2$delim\e[34m$3\e[0m"
			;;
			*)
				echo -e "$indent$2$delim$3"
			;;
		esac
	;;
esac
}

#whoami
#DO NOT USE ROOT FOR ANSIBLE. Creating ansible_user
eval `ssh-agent -s`
prn_txt 2 "Loking for" "Ansible user" blue
ansible_user=`sshpass -p "$ROOT_PASS" ssh root@$HOST_IP "sed 's/:.*//' /etc/passwd | grep ansible"`
	if [ "x$ansible_user" = "x" ]; then
	prn_txt 3 "Ansible user" "Doesn't exist." red

	create_ansible_user=`sshpass -p "$ROOT_PASS" ssh root@$HOST_IP "useradd ansible -ou 0 -g 0"`
	prn_txt 2 "Ansible user" "Created. Checking" blue

		ansible_user_check=`sshpass -p "$ROOT_PASS" ssh root@$HOST_IP "sed 's/:.*//' /etc/passwd | grep ansible"`
		if [ "x$ansible_user_check" = "x" ]; then
		prn_txt 3 "Ansible user wesn't created" "Error" red
		exit 0
		else
		prn_txt 3 "Ansible user" "created" green
		prn_txt 3 "Password" "changed" green
		sshpass -p "$ROOT_PASS" ssh root@$HOST_IP "echo 'ansible:$ROOT_PASS' | chpasswd"
		fi
	else
	prn_txt 3 "Ansible user" "exists" green
	fi

#Checking distr. If it CentOS, then checking SELinux for disable.
distr=`sshpass -p "$ROOT_PASS" ssh root@$HOST_IP  "cat /etc/*-release | grep CentOS"`
	if [ -n "$distr" ]; then
	prn_txt 2 "Distr" "CentOS" blue
	se_disable=`sshpass -p "$ROOT_PASS" ssh root@$HOST_IP "cat /etc/selinux/config | grep enforcing"`

		if [ -n "$se_disable" ]; then
		prn_txt 3 "SELinux" "Enabled. Disabling..." red
		sshpass -p "$ROOT_PASS" ssh root@$HOST_IP "sed -i 's/enforcing/disabled/g' /etc/selinux/config"

			#More check. If not disabled, then exit
			se_disable_second=`sshpass -p "$ROOT_PASS" ssh root@$HOST_IP "cat /etc/selinux/config | grep enforcing"`
			if [ -n "$se_disable_second" ]; then
			prn_txt 3 "SELinux" "Wasn't disabled. Error" red
			exit 1
			else
			prn_txt 3 "SELinux" "Disabled. Rebooting" green
			sshpass -p "$ROOT_PASS" ssh root@$HOST_IP "reboot"
			fi

		else
		prn_txt 3 "SELinux" "Disabled. No actions needed" green
        sshpass -p "$ROOT_PASS" ssh root@$HOST_IP "reboot"
        fi
			
	else 
	prn_txt 3 "Distr is not CentOS" "No extions needed" green
	exit 0
	fi
