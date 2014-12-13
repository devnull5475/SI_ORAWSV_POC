#!/bin/python
import suds
from suds.client import Client

u = 'http://owsx:owsx_user@localhost:8080/orawsv/OWSX/OWSX_UTL/PAY_RAISE'
h = {'User-Agent':'Mozilla/4.0'}
client = Client(u)
print(client)
