#!/usr/bin/python3

import sys
import getopt
import smtplib

FILE = "smtp.txt"
smtpinfo = []
text = {}

try:
    opts, args = getopt.getopt(sys.argv[1:], "h:t:")
except getopt.GetoptError:
    print("no text for sending!")
    sys.exit(1)

for opt, arg in opts:
    text[opt] = arg

if (len(text) != 2):
    print("this program require a subject and main text!")
    sys.exit(1)

with open(FILE) as fin:
    for line in fin:
        smtpinfo.append(line[:-1])

if len(smtpinfo) != 4:
    print("SMTP input file has wrong format!")
    sys.exit(1)

message = "To: {1}{0}From: {2}{0}Subject: {3}{0}{0}{4}".format("\r\n",
        smtpinfo[0], smtpinfo[0], text['-h'], text['-t'])

try:
    smtpObj = smtplib.SMTP(smtpinfo[2], int(smtpinfo[3]))
    smtpObj.ehlo()
    smtpObj.starttls()
    smtpObj.login(smtpinfo[0], smtpinfo[1])
    smtpObj.sendmail(smtpinfo[0], [smtpinfo[0]], message)
    smtpObj.quit()
except smtplib.SMTPException:
    print("Sending failed!")
    sys.exit(1)
