import os
import sys
import hashlib
sys.path.append(os.path.abspath(os.path.dirname(os.path.abspath(__file__))+"/../build/"))
from constants import *
 
def getWord(b, k, n=4):
	return sum(list(map(lambda c: b[k+c]<<(c*8),range(n))))

def getHash(b, k, n):
	return bytearray(hashlib.sha256(crodata[(k):(k+n)]).digest())

crofn=sys.argv[1]
crrpatchfn=sys.argv[2]

crodata=bytearray(open(crofn,"rb").read())
crrdata=bytearray(b'\x00'*0x20*CRR_HASHES)
hash=getHash(crodata,0x00,0x80)
for i in range(0,0x20*CRR_HASHES,0x20):
	crrdata[i:(i+0x20)]=hash
open(crrpatchfn,"wb").write(crrdata)
