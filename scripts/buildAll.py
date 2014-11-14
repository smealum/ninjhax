import sys
import os
import itertools

# 0 : firm, 1 : cn, 2 : spider, 3 : ro

def isVersionPossible(v):
	if v[0]=="PRE5":
		return v[3]<=1024 and v[2]<=2050
	else:
		return v[3]>=2049

firmVersions=["PRE5", "POST5", "N3DS"]
cnVersions=["WEST", "JPN"]
spiderVersions=[2050, 3074, 4096]
roVersions=[1024, 2049, 3074, 4096]

a=[firmVersions, cnVersions, spiderVersions, roVersions]

cnt=0
for v in (list(itertools.product(*a))):
	if isVersionPossible(v):
		os.system("make clean")	
		os.system("make FIRMVERSION="+str(v[0])+" CNVERSION="+str(v[1])+" SPIDERVERSION="+str(v[2])+" ROVERSION="+str(v[3]))
print(cnt)
