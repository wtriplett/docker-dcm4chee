#!/usr/bin/env python
import string
newElement =   "<application-policy name = 'web-reporting'>\n \
       <authentication>\n \
          <login-module code='org.jboss.security.auth.spi.DatabaseServerLoginModule'\n \
             flag = 'required' >\n \
             <module-option name = 'dsJndiName'>java:/pacsDS</module-option>\n \
             <module-option name = 'principalsQuery'>select passwd from users where user_id=?</module-option>\n \
             <module-option name = 'rolesQuery'>select roles, 'Roles' from roles where user_id=?</module-option>\n \
             <module-option name = 'hashEncoding'>base64</module-option>\n \
             <module-option name = 'hashCharset'>UTF-8</module-option>\n \
             <module-option name = 'hashAlgorithm'>SHA-1</module-option>\n \
          </login-module>\n \
          <login-module code='org.dcm4chee.audit.login.AuditLoginModule'\n \
             flag = 'optional' >\n \
          </login-module>\n \
       </authentication>\n \
    </application-policy>"
newElementArray = newElement.split('\n')
file = open('login-config.xml', 'r')
fileArray = file.read().split('\n')
global last_index
for index, fileLine in enumerate(fileArray):
    if "application-policy>" in fileLine:
        last_index = index
fileArray[last_index + 1: len(newElementArray)] = [line+"\n" for line in newElementArray]
file.close()
file2 = open('login-config.xml', 'w')
file2.write(string.join(fileArray))
file2.close()
