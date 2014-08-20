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

all: spider_initial_rop.bin

clean:
	@rm -f spider_initial_rop.bin
	@cd $(SPIDERVERSION) && make clean
	@echo "all cleaned up !"

spider_initial_rop.bin:
	@cd $(SPIDERVERSION) && make
	@cp $(SPIDERVERSION)/$@ ./
	@python $(SCRIPTS)/obfuscator5000.py $@
