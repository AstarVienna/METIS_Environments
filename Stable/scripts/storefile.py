"""Store a test file.

env data_protocol=https data_server=localhost data_port=8013 database_engine=filebased python storefile.py

curl -k https://localhost:8013/testfile.txt
"""
from common.database.DataObject import DataObject
from common.config.Environment import Env

fn_test = "testfile.txt"

print(f"Going to store ${fn_test} on ${Env['data_server']} port ${Env['data_port']}.")

mydo = DataObject()
mydo.filename = fn_test
mydo.store()
