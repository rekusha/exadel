использование ансибл без создания инвентори файла
ansible all -i xx.xx.xx.xx, -m ping -u username --private-key /path/to/key_file

# Task 4: Ansible for beginners  
## Важные моменты:  
  
1. Посмотреть что такое Configuration Management Systems.  
2. Преимущества и недостатки Ansible над другими инструментами   
3. Ознакомиться с основами ансибла и синтаксисом YAML  
4. Основы работы с Ansible из официальной документации  
**EXTRA** Jinja2 templating - почитать документацию  
  
## Tasks:  
   1. Развернуть три виртуальные машины в облаке. На одну из них (control_plane) установить Ansible.  
   1. Ping pong - выполнить встроенную команду ансибла ping. Пинговать две другие машины.  
   1. Первый Плейбук - написать плейбук по установке Docker на две машины и выполнить его.  
       
   **EXTRA 1.** Написать плейбук по установке Docker и одного из (LAMP/LEMP стек, Wordpress, ELK, MEAN - GALAXY нельзя) в Docker.  
   **EXTRA 2.** Вышесказанные плейбуки не должны иметь дефолтных кредов к базам данных и/или админке.  
   **EXTRA 3.**  Для исполнения плейбуков должны использоваться dynamic inventory (GALAXY можно)  
  
Результатом выполнения данного задания  являются ansible файлы в вашем GitHub.   

------

1. установка ansible
```
sudo apt-add-repository ppa:ansible/ansible && sudo apt-get update && sudo apt-get install -y ansible  
```

2.
```
$ mkdir ansible
$ mkdir ansible/keys # положить нужные ключи
$ chmod 400 ansible/keys/key_name.pem

$ printf '[aws]\ninstance1 ansible_host=3.127.64.37 ansible_user=ubuntu ansible_private_key_file=/home/ubuntu/ansible/keys/ssh_key.pem\ninstance2 ansible_host=18.193.127.247 ansible_user=ubuntu ansible_private_key_file=/home/ubuntu/ansible/keys/ssh_key.pem' > ansible/hosts.txt

ubuntu@ip-172-31-7-51:~/$ ansible/ansible -i hosts.txt all -m ping



instance2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
instance1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

3.
```
---
- name: install docker in all instance
  hosts: all
  become: yes

  tasks:
    - name: install aptitude using apt
      apt: name=aptitude state=latest update_cache=yes force_apt_get=yes

    - name: install required packages
      apt: name={{ item }} state=latest update_cache=yes
      loop: [ 'apt-transport-https', 'ca-certificates', 'curl', 'software-properties-common']

    - name: gpg apt key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: add docker repository
      apt_repository:
        repo: deb https://download.docker.com/linux/ubuntu bionic stable
        state: present

    - name: update apt and install docker-ce
      apt: update_cache=yes name=docker-ce state=latest
```

$ ansible-playbook -i hosts.txt playbooks/without_extra.yaml

```
$ ansible-playbook -i hosts.txt with_extra.yaml 


PLAY [install docker in all instance] ************************************************************************************

TASK [Gathering Facts] ***************************************************************************************************
ok: [ununtu_local]

TASK [install aptitude using apt] ****************************************************************************************
changed: [ununtu_local]

TASK [install required packages] *****************************************************************************************
changed: [ununtu_local] => (item=apt-transport-https)
ok: [ununtu_local] => (item=ca-certificates)
ok: [ununtu_local] => (item=curl)
changed: [ununtu_local] => (item=software-properties-common)

TASK [gpg apt key] *******************************************************************************************************
changed: [ununtu_local]

TASK [add docker repository] *********************************************************************************************
changed: [ununtu_local]

TASK [update apt and install docker-ce] **********************************************************************************
changed: [ununtu_local]

PLAY RECAP ***************************************************************************************************************
ununtu_local               : ok=6    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```



--------------------------------------------------------------------------------------------------------------------------
--EXTRAS_1--
--------------------------------------------------------------------------------------------------------------------------
add some packages to install in section with name 'install required packages' in our without_extra.yaml file  
'python3-pip', 'virtualenv', 'python3-setuptools'  

and add instructions for create and run docker containers with lamp  
```
- name: docker module for python install
      pip:
        name: docker

    - name: httpd container
      docker_container:
        name: apache
        image: httpd
        ports: ['80:80']

    - name: mysql container
      docker_container:
        name: mysql
        image: mysql
        ports: ['3306:3306']
        hostname: mysql
        env:
          MYSQL_ROOT_PASSWORD: "{{ task5mysql_root_password }}"
          MYSQL_USER: task5mysql
          MYSQL_PASSWORD: "{{ task5mysql_password }}"
          MYSQL_DATABASE: TASK5TESTDB

    - name: phpmyadmin container
      docker_container:
        name: phpmyadmin
        image: phpmyadmin
        ports: ['81:80']
        env:
          PMA_HOST: "{{ task5_phpmyadmin_db_ip }}"
          PMA_USER: root
          PMA_PASSWORD: "{{ task5_phpmyadmin_password }}"
```

--------------------------------------------------------------------------------------------------------------------------
--EXTRAS_2--
--------------------------------------------------------------------------------------------------------------------------
create file vars/vars.yaml with credentionals and vars  
after file save and ready, encrypt them with command 'ansible-vault encrypt vars/vars.yaml'  
afer it in vars.yaml we have something like this:  

$ANSIBLE_VAULT;1.1;AES256
63303765343235616164366564306163353639333033326566316464333761663765666432343463
3235616634346564373133396234363363363063336435620a366331336536333763356533333938
64376662313430346662333961356639396566356264306132613765323362303031386466663364
3664336234636165630a663334653839313635346530343937343334383331663562363933623234
61363965383434366138316437353334643138646633343332613030323364613236646138356339
34636437306538323633353934306430626561653761633733333666653039313164316563363262
36356462623438303635623638663138323738333833363466303763393962613734396333353061
63333133386566636366306437636464653835363664303361373964386534623632313136613631
62633436303337636333386630316334633862373836396265666336363661386535663135663133
30616439346463326639376339333761643333386161366431373431626564616264343834383765
30393265663935316431383963626631346330313435393831323738343231323366613461663136
64336562373466363733

to use this file with ansible need add option '--ask-vault-pass' to command line  
or you can create temporary file with password and use '--vault-password-file <filename>' option  

--------------------------------------------------------------------------------------------------------------------------
--EXTRAS_3--
--------------------------------------------------------------------------------------------------------------------------
```
export AWS_ACCESS_KEY_ID='secretkey'
export AWS_SECRET_ACCESS_KEY='secretacceskey'
pip install boto3

```

ansible.cfg
```
[defaults]
host_key_checking = false

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml
```

aws_ec2.yml
```
---
plugin: amazon.aws.aws_ec2
regions:
  - eu-central-1
keyed_groups:
  - key: tags.Name
  - key: tags.Group
filters:
  instance-state-name : running
compose:
  ansible_host: public_ip_address
```

/exadel/task4/extra/3$ ansible -i aws_ec2.yml all -m ping -u ubuntu --private-key /home/rekusha/git/keys/ec2.pem
```
ec2-35-159-12-18.eu-central-1.compute.amazonaws.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
ec2-18-184-18-85.eu-central-1.compute.amazonaws.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
ec2-3-66-211-75.eu-central-1.compute.amazonaws.com | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}

``` 
