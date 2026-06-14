import json

with open('C:/Users/sawyelin/AppData/Local/crush/crush.json') as f:
    d = json.load(f)

d['mcp'] = {
    'remote-android': {
        'type': 'http',
        'url': 'http://192.168.1.188:8080/mcp',
        'headers': {
            'headervbear': '076f8e09-0259-49b9-8695-d2daf9e4a76f'
        }
    }
}

with open('C:/Users/sawyelin/AppData/Local/crush/crush.json', 'w') as f:
    json.dump(d, f, indent=2)

print('Config updated')