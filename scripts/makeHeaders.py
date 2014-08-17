import sys
import ast

def outputConstantsH(d):
	out=""
	out+=("#ifndef CONSTANTS_H")+"\n"
	out+=("#define CONSTANTS_H")+"\n"
	for k in d:
		out+=("	#define "+k+" ("+str(d[k])+")")+"\n"
	out+=("#endif")+"\n"
	return out

def outputConstantsS(d):
	out=""
	for k in d:
		out+=(k+" equ ("+str(d[k])+")")+"\n"
	return out

if len(sys.argv)<2:
	print("use : "+sys.argv[0]+" <extensionless_output_name> <input_file1> <input_file2> ...")
	exit()

d={}

for fn in sys.argv[2:]:
	s=open(fn,"r").read()
	if len(s)>0:
		d.update(ast.literal_eval(s))

open(sys.argv[1]+".h","w").write(outputConstantsH(d))
open(sys.argv[1]+".s","w").write(outputConstantsS(d))
