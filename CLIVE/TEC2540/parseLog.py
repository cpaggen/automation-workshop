#!/usr/bin/env python3
import json
import pprint
import sys

#
# filename is expected to have structure
#
# url: https://10.48.168.3/api/node/mo/uni/fabric/monfab-default/slsrc-fabricDefaultSyslog.json
# payload{"syslogSrc":{"attributes":{"dn":"uni/fabric/monfab-default/slsrc-fabricDefaultSyslog"}}
# response: {"totalCount":"0","imdata":[]}
#
# payload needs to be a proper JSON string; it must be prefixed by the word 'payload' as shown here
#

schema = '''
---
- hosts: 10.48.168.2
  connection: local
  vars:
  tasks:
  - name: POST json to APIC
    aci_rest:
      hostname: '{{ inventory_hostname }}'
      username: '{{ aci_username }}'
      password: '{{ aci_password }}'
      validate_certs: no
      use_ssl: yes
      use_proxy: no
      path: /api/mo/uni.json
      method: post
      content:
        %s
    delegate_to: localhost
'''

def parseLog(fp):
    jpayload = fp.readlines()[1]
    jpayload = jpayload[7:-1]
    fp.close()
    parsed = json.loads(jpayload)
    ansible = schema % json.dumps(parsed, indent=12)
    return(ansible)

if len(sys.argv) != 2:
    sys.exit('Provide filename please')

fname = sys.argv[1]
try:
    fp = open(fname,'r')
except FileNotFoundError:
    sys.exit('File not found')

jpayload = parseLog(fp)
print(jpayload)

