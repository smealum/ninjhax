import sys
import hashlib
 
def getWord(b, k, n=4):
	return sum(list(map(lambda c: b[k+c]<<(c*8),range(n))))

def getHash(b, k, n):
	return bytearray(hashlib.sha256(crodata[(k):(k+n)]).digest())

crofn=sys.argv[1]
# crrfn=sys.argv[2]

crodata=bytearray(open(crofn,"rb").read())

# print([hex(v) for v in getHash(crodata,getWord(crodata, 0xB0),getWord(crodata, 0xB4))])

crodata[0x00:0x20]=getHash(crodata,0x80,getWord(crodata, 0xB0)-0x80)
crodata[0x20:0x40]=getHash(crodata,getWord(crodata, 0xB0),getWord(crodata, 0xB4))
crodata[0x40:0x60]=getHash(crodata,getWord(crodata, 0xB0)+getWord(crodata, 0xB4),getWord(crodata, 0xB8)-(getWord(crodata, 0xB0)+getWord(crodata, 0xB4)))

# crrdata=bytearray(open(crrfn,"rb").read())
# crrdata[0x360:0x380]=getHash(crodata,0x00,0x80)

open(crofn,"wb").write(crodata)
# open(crrfn,"wb").write(crrdata)
