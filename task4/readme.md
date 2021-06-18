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
mkdir ansible
mkdir ansible/keys # положить нужные ключи
chmod 400 ansible/keys/key_name.pem

printf '[aws]\ninstance1 ansible_host=3.127.64.37 ansible_user=ubuntu ansible_private_key_file=/home/ubuntu/ansible/keys/ssh_key.pem\ninstance2 ansible_host=18.193.127.247 ansible_user=ubuntu ansible_private_key_file=/home/ubuntu/ansible/keys/ssh_key.pem' > ansible/hosts.txt

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

