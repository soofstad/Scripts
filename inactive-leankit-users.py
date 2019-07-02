import json
import csv
data = json.loads(raw_data)

users = [ {'name': user['fullName'],
    'lastAccess': user['lastAccess'],
    'email': user['emailAddress'],
    'enabled': user['enabled']}
    for user in data['users'] if user['enabled'] == True]

with open('leankit-user.csv', 'w') as file:
    for user in users:
        file.write(f'''{user['name']},{user['lastAccess']},{user['email']}\n''')

print("test")
