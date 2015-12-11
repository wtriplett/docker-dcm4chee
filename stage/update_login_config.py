#!/usr/bin/env python

import xml.etree.ElementTree as ET
import copy

doctype = """<?xml version='1.0'?>
<!DOCTYPE policy PUBLIC
      '-//JBoss//DTD JBOSS Security Config 3.0//EN'
      'http://www.jboss.org/j2ee/dtd/security_config.dtd'>"""
tree = ET.parse('login-config.xml')
root = tree.getroot()
global tmpEleme
for ap in root:
    if(ap.attrib.get("name") == "dcm4chee"):
        tmpEleme = copy.copy(ap)

tmpEleme.set("name", "web-reporting")
root.append(tmpEleme)
xml_string = '\n'.join([doctype, ET.tostring(root, 'utf-8')])
open('login-config.xml', 'w').write(xml_string)
