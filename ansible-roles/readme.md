ansible - opensource push request (не требует агентов на удаленных системах)  
  
<details><summary>requirements</summary>
<pre>
server requirement:  
linux OS  
python 3.5+ (2.6+)   
ssh-key  
</pre>
<pre>
client requirement:   
python 3.5+ (2.6+)  
port 22 (or other port for ssh)  
linux (Admin user/pass)  
ssh-key.pub  
</pre>
</details>  

<details><summary>install ansible</summary>
<pre>
sudo apt-add-repository ppa:ansible/ansible  
sudo apt-get update  
sudo apt-get install -y ansible
</pre>
</details>

<details><summary>ansible ad-hoc</summary>
<pre>
ansible <groupe_name/server_name/ip> -m <module_name> -a <argument>

ansible all -m ping
ansible all -m shell -a "uptime"
ansible all -m command -a "uptime" # тоже что и shell но без пайплайнов и энвайремент переменных
ansible all -m copy -a "src=filename dst=/home mode=777" -b  # -b это sudo привелегии для выполняемой команды
ansible all -m file -a "path=/home/file.txt state=absent" -b  # состояние файла отсутствует (проверяет что такого файла нет по пути, а если есть то удаляет)

ansible all -m apt -a "name=httpd state=latest(absent)" -b  # установка пакетов с помощью apt
ansible all -m service -a "name=httpd state=started enabled=yes" -b  # приложение запустить и enabled - добавить в автозапуск
ansible all -m apt -a "name=httpd state=absent" -b  # удаление пакета

ansible all -m uri -a "url=http://site.com"  # проверка доступности ресурса по имени сайта
ansible all -m uri -a "url=http://site.com return_content=yes"  # return_content=yes - возвращает контент курл запроса (по умолчанию не возвращает)
ansible all -m get_url -a"url=link_to_file dest=~/"  # скачать файл из интернета по указанному пути

</pre>
</details>

<details><summary>ansible infrastructure</summary>
<details><summary>hosts (inventory)</summary>
  здесь должны храниться только группы, имя хостов(при желании) и адреса
<pre>
10.0.0.2
10.0.0.3  # эти поподают в группу ungrouped и all

[task3]
task3_docker        ansible_host=192.168.0.254

[task4]
task4_ansible       ansible_host=192.168.0.254

[task5]
task5_jenkins       ansible_host=192.168.0.254 

[task6]
task6_mysql         ansible_host=192.168.0.254 
task6_postgres      ansible_host=192.168.0.254 

[task7]
task7_elk_grafana   ansible_host=192.168.0.254 

[exadel:children]
task3
task4
task5
task6
task7

</pre>
</details>
  
<details><summary>ansible.cfg</summary>
  здесь должны храниться конфигурации как общие так и для конерктных групп и хостов
<pre>
[defaults]
host_key_cheking               = false
inventiry                      = ./hosts
ansible_user                   = ubuntu 
ansible_ssh_private_key_title  = ~/.ssh/exadel_key
</pre>
</details></details>
