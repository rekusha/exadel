#!/usr/bin/python3
import pandas
import csv

sheet_url = "https://docs.google.com/spreadsheets/d/1bJ6aDyDSBPAbck56ji6q98rw8S69i_cDymm4gN0vu3o/edit#gid=0"
url_1 = sheet_url.replace('/edit#gid=', '/export?format=csv&gid=')

x = pandas.read_csv(url_1)

student_header = ['Surname Name', 'StudentId']
student_row = []
task_header = ['StudentId', 'Task1', 'Task2', 'Task3', 'Task4']
task_row = []

for _ in range(len(x)):
    if str(x['Unnamed: 0'][_])[:1].isdigit():
        student_row.append({'Surname Name': x['Surname Name'][_],
                            'StudentId': int(x['Unnamed: 0'][_])})
        task_row.append({'StudentId': int(x['Unnamed: 0'][_]),
                         'Task1': x['Task1 - Git/Github'][_],
                         'Task2': x['Task2 - AWS/Clouds'][_],
                         'Task3': x['Task3 - Docker'][_],
                         'Task4': x['Task4 - Ansible'][_]})


def csv_write(filename, header, rows):
    with open(filename, 'w', encoding='UTF8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=header)
        writer.writeheader()
        writer.writerows(rows)


csv_write('students.csv', student_header, student_row)
csv_write('tasks.csv', task_header, task_row)
