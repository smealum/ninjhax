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

all: ro_initial_rop.bin

clean:
	@rm -f ro_initial_rop.bin
	@cd $(ROVERSION) && make clean
	@echo "all cleaned up !"

ro_initial_rop.bin:
	@cd $(ROVERSION) && make
	@cp $(ROVERSION)/$@ ./
	@python $(SCRIPTS)/obfuscator5000.py $@
