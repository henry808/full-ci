import os
from flask import Flask

app = Flask(__name__)

env = os.environ.get('ENV')

@app.route('/')
def hello_world():
    return f'Hello, World!\nEnvironment: {env}'


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
