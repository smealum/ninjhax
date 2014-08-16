import os
import sys
import struct
import ctypes

def getWord(b, k, n=4):
	return sum(list(map(lambda c: b[k+c]<<(c*8),range(n))))

def loadSP(fn):
	f=open(fn,"rb")

	P=[]
	for i in range(18):
		P.append(struct.unpack("I",f.read(4))[0])

	S=[[],[],[],[]]

	for i in range(4):
		for j in range(256):
			S[i].append(struct.unpack("I",f.read(4))[0])

	f.close()

	return S, P

# 2 functions stolen from http://felipetonello.com/scripts/python/blowfish.txt
def F(S, P, xl):
	a = (xl & 0xFF000000) >> 24
	b = (xl & 0x00FF0000) >> 16
	c = (xl & 0x0000FF00) >> 8
	d = xl & 0x000000FF
	return ((S[0][a] + S[1][b]) ^ S[2][c]) + S[3][d];

def cipher(S, P, xl, xr, direction):
	if direction == 0: #ENCRYPT
		for i in range (16):
			xl = xl ^ P[i]
			xr = F(S,P,xl) ^ xr
			xl, xr = xr, xl
		xl, xr = xr, xl
		xr = xr ^ P[16]
		xl = xl ^ P[17]
	else: #DECRYPT
		for i in range (17, 1, -1):
			xl = xl ^ P[i]
			xr = F(S,P,xl) ^ xr
			xl, xr = xr, xl
		xl, xr = xr, xl
		xr = xr ^ P[1]
		xl = xl ^ P[0]
	return xl, xr

def encrypt(din,dout):
	l=len(din)
	for k in range(0,l,8):
		l=getWord(din,k)
		r=getWord(din,k+4)
		ret=cipher(S,P,l,r,0)
		dout[(k):(k+4)]=struct.pack("I",ret[0]&0xFFFFFFFF)
		dout[(k+4):(k+8)]=struct.pack("I",ret[1]&0xFFFFFFFF)

path="./"
if len(sys.argv)>3:
	path=sys.argv[3]

data=bytearray(open(sys.argv[1],"rb").read())

padding=8-(len(data)%8)
for k in range(padding):
	data.append(0)

dataOut=data[:]
(S,P)=loadSP(path+"/blowfish_processed.bin")
encrypt(data,dataOut)

open(sys.argv[2],"wb").write(dataOut)
