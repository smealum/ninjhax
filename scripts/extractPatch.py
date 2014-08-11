import sys
 
def getWord(b, k, n=4):
	return sum(list(map(lambda c: b[k+c]<<(c*8),range(n))))

origfn=sys.argv[1]
patchfn=sys.argv[2]
outfn=sys.argv[3]
offset=int(sys.argv[4], 0)

origdata=bytearray(open(origfn,"rb").read())
patchdata=bytearray(open(patchfn,"rb").read())

if len(sys.argv)>5:
	size=int(sys.argv[5], 0)
else:
	k=offset
	while getWord(origdata,k,n=8)!=getWord(patchdata,k,n=8):
		k+=8
	size=k-offset

open(outfn,"wb").write(patchdata[offset:(offset+size)])
