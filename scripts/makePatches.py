import sys
import os
sys.path.append(os.path.abspath(os.path.dirname(os.path.abspath(__file__))+"/../build/"))
from constants import *

os.system("python "+sys.argv[1]+"/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch0.bin "+str(CRO_PATCH0_OFFSET)+" 0x60 full")
os.system("python "+sys.argv[1]+"/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch1.bin "+str(CRO_PATCH1_OFFSET)+" "+str(CRO_PATCH2_OFFSET))
os.system("python "+sys.argv[1]+"/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch2.bin "+str(CRO_PATCH2_OFFSET)+" "+str(CRO_PATCH3_OFFSET))
os.system("python "+sys.argv[1]+"/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch3.bin "+str(CRO_PATCH3_OFFSET)+" "+str(CRO_PATCH4_OFFSET))
os.system("python "+sys.argv[1]+"/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch4.bin "+str(CRO_PATCH4_OFFSET)+" "+str(CRO_SIZE))
