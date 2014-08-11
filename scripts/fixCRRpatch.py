import sys
import hashlib
 
def getWord(b, k, n=4):
	return sum(list(map(lambda c: b[k+c]<<(c*8),range(n))))

def getHash(b, k, n):
	return bytearray(hashlib.sha256(crodata[(k):(k+n)]).digest())

crofn=sys.argv[1]
crrpatchfn=sys.argv[2]

crodata=bytearray(open(crofn,"rb").read())

crrdata=bytearray(open(crrpatchfn,"rb").read())
crrdata[0x00:0x20]=getHash(crodata,0x00,0x80)
crrdata[0x20:0x40]=getHash(crodata,0x00,0x80)

open(crrpatchfn,"wb").write(crrdata)
