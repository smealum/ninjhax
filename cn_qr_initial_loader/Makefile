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

all: cn_qr_initial_loader.bin.png

clean:
	@rm -f cn_qr_initial_loader.bin.png
	@cd WEST && make clean
	@cd JPN && make clean
	@echo "all cleaned up !"

cn_qr_initial_loader.bin.png:
	@cd $(CNVERSION) && make
	@cp $(CNVERSION)/$@ ./
