ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

ifeq ($(strip $(CTRULIB)),)
$(error "Please set CTRULIB in your environment. export DEVKITARM=<path to>ctrulib/libctru")
endif

ifeq ($(filter $(DEVKITARM)/bin,$(PATH)),)
export PATH:=$(DEVKITARM)/bin:$(PATH)
endif

SCRIPTS = "../scripts"

.PHONY: oss_new.cro

oss_new.cro: oss.cro
	@python $(SCRIPTS)/makeROP.py ../build/ro_initial_rop.bin oss.cro out_oss.cro
	@armips oss.s
	@python $(SCRIPTS)/fixCRO.py out_oss.cro

oss.cro:
	@cp $(SPIDERVERSION)/$@ ./

clean:
	@rm -f oss.cro
	@rm -f out_oss.cro
	@echo "all cleaned up !"
