import sys
import ast

def outputConstantsH(d):
	out=""
	out+=("#ifndef CONSTANTS_H")+"\n"
	out+=("#define CONSTANTS_H")+"\n"
	for k in d:
		out+=("	#define "+k[0]+" ("+str(k[1])+")")+"\n"
	out+=("#endif")+"\n"
	return out

def outputConstantsS(d):
	out=""
	for k in d:
		out+=(k[0]+" equ ("+str(k[1])+")")+"\n"
	return out

def outputConstantsPY(d):
	out=""
	for k in d:
		out+=(k[0]+" = ("+str(k[1])+")")+"\n"
	return out

if len(sys.argv)<2:
	print("use : "+sys.argv[0]+" <extensionless_output_name> <input_file1> <input_file2> ...")
	exit()

l=[]

for fn in sys.argv[2:]:
	s=open(fn,"r").read()
	if len(s)>0:
		l+=(ast.literal_eval(s))

open(sys.argv[1]+".h","w").write(outputConstantsH(l))
open(sys.argv[1]+".s","w").write(outputConstantsS(l))
open(sys.argv[1]+".py","w").write(outputConstantsPY(l))
