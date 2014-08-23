ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

ifeq ($(strip $(CTRULIB)),)
$(error "Please set CTRULIB in your environment. export DEVKITARM=<path to>ctrulib/libctru")
endif

ifeq ($(filter $(DEVKITARM)/bin,$(PATH)),)
export PATH:=$(DEVKITARM)/bin:$(PATH)
endif

# FIRMVERSION = OLD_MEMMAP
# FIRMVERSION = NEW_MEMMAP

# CNVERSION = WEST
# CNVERSION = JPN
# ROVERSION = 1024
# ROVERSION = 2049
# ROVERSION = 3074
# ROVERSION = 4096
# SPIDERVERSION = 2050
# SPIDERVERSION = 3074
# SPIDERVERSION = 4096

export FIRMVERSION
export CNVERSION
export ROVERSION
export SPIDERVERSION

OUTNAME = $(FIRMVERSION)_$(CNVERSION)_$(SPIDERVERSION)_$(ROVERSION)

SCRIPTS = "scripts"

.PHONY: directories all build/constants firm_constants/constants.txt ro_constants/constants.txt spider_constants/constants.txt cn_constants/constants.txt cn_qr_initial_loader/cn_qr_initial_loader.bin.png cn_save_initial_loader/cn_save_initial_loader.bin cn_secondary_payload/cn_secondary_payload.bin cn_bootloader/cn_bootloader.bin spider_initial_rop/spider_initial_rop.bin spider_thread0_rop/spider_thread0_rop.bin oss_cro/out_oss.cro build/ro_initial_code.bin build/ro_initial_rop.bin build/spider_code.bin

all: directories build/constants q/$(OUTNAME).png p/$(OUTNAME).bin build/cn_save_initial_loader.bin
directories:
	@mkdir -p build && mkdir -p build/cro
	@mkdir -p p
	@mkdir -p q

q/$(OUTNAME).png: build/cn_qr_initial_loader.bin.png
	@cp build/cn_qr_initial_loader.bin.png q/$(OUTNAME).png

p/$(OUTNAME).bin: build/cn_secondary_payload.bin
	@cp build/cn_secondary_payload.bin p/$(OUTNAME).bin

firm_constants/constants.txt:
	@cd firm_constants && make
ro_constants/constants.txt:
	@cd ro_constants && make
spider_constants/constants.txt:
	@cd spider_constants && make
cn_constants/constants.txt:
	@cd cn_constants && make

build/constants: firm_constants/constants.txt ro_constants/constants.txt spider_constants/constants.txt cn_constants/constants.txt
	@python $(SCRIPTS)/makeHeaders.py $(FIRMVERSION) $(CNVERSION) $(SPIDERVERSION) $(ROVERSION) build/constants $^

build/cn_qr_initial_loader.bin.png: cn_qr_initial_loader/cn_qr_initial_loader.bin.png
	@cp cn_qr_initial_loader/cn_qr_initial_loader.bin.png build
cn_qr_initial_loader/cn_qr_initial_loader.bin.png:
	@cd cn_qr_initial_loader && make


build/cn_save_initial_loader.bin: cn_save_initial_loader/cn_save_initial_loader.bin
	@cp cn_save_initial_loader/cn_save_initial_loader.bin build
cn_save_initial_loader/cn_save_initial_loader.bin:
	@cd cn_save_initial_loader && make


build/cn_secondary_payload.bin: cn_secondary_payload/cn_secondary_payload.bin
	@python $(SCRIPTS)/blowfish.py cn_secondary_payload/cn_secondary_payload.bin build/cn_secondary_payload.bin scripts
cn_secondary_payload/cn_secondary_payload.bin: build/cn_save_initial_loader.bin build/spider_hook_rop.bin build/spider_initial_rop.bin build/spider_thread0_rop.bin build/cn_bootloader.bin
	@cp build/cn_save_initial_loader.bin cn_secondary_payload/data
	@cp build/spider_hook_rop.bin cn_secondary_payload/data
	@cp build/spider_initial_rop.bin cn_secondary_payload/data
	@cp build/spider_thread0_rop.bin cn_secondary_payload/data
	@cp build/cn_bootloader.bin cn_secondary_payload/data
	@cd cn_secondary_payload && make


build/cn_bootloader.bin: cn_bootloader/cn_bootloader.bin
	@cp cn_bootloader/cn_bootloader.bin build
cn_bootloader/cn_bootloader.bin:
	@cd cn_bootloader && make


build/spider_hook_rop.bin: spider_hook_rop/spider_hook_rop.bin
	@cp spider_hook_rop/spider_hook_rop.bin build
spider_hook_rop/spider_hook_rop.bin:
	@cd spider_hook_rop && make


build/spider_initial_rop.bin: spider_initial_rop/spider_initial_rop.bin
	@cp spider_initial_rop/spider_initial_rop.bin build
spider_initial_rop/spider_initial_rop.bin:
	@cd spider_initial_rop && make


build/spider_thread0_rop.bin: spider_thread0_rop/spider_thread0_rop.bin
	@cp spider_thread0_rop/spider_thread0_rop.bin build
spider_thread0_rop/spider_thread0_rop.bin: build/oss.cro
	@cd spider_thread0_rop && make


build/oss.cro: oss_cro/out_oss.cro
	@cp oss_cro/out_oss.cro build
	@python $(SCRIPTS)/makePatches.py $(SCRIPTS)
	@python $(SCRIPTS)/fixCRRpatch.py build/out_oss.cro build/cro/patchCRR.bin
oss_cro/out_oss.cro: build/ro_initial_rop.bin build/ro_initial_code.bin build/spider_code.bin
	@cd oss_cro && make 


build/ro_initial_rop.bin: ro_initial_rop/ro_initial_rop.bin
	@cp ro_initial_rop/ro_initial_rop.bin build
ro_initial_rop/ro_initial_rop.bin: build/constants
	@cd ro_initial_rop && make


build/ro_initial_code.bin: ro_initial_code/ro_initial_code.bin
	@cp ro_initial_code/ro_initial_code.bin build
ro_initial_code/ro_initial_code.bin: build/ro_command_handler.bin build/constants
	@cd ro_initial_code && make


build/ro_command_handler.bin: ro_command_handler/ro_command_handler.bin
	@cp ro_command_handler/ro_command_handler.bin build
ro_command_handler/ro_command_handler.bin: build/constants
	@cd ro_command_handler && make


build/spider_code.bin: spider_code/spider_code.bin
	@cp spider_code/spider_code.bin build
spider_code/spider_code.bin:
	@cd spider_code && make


clean:
	@rm -rf build/*
	@cd firm_constants && make clean
	@cd cn_constants && make clean
	@cd ro_constants && make clean
	@cd spider_constants && make clean
	@cd cn_bootloader && make clean
	@cd cn_qr_initial_loader && make clean
	@cd cn_save_initial_loader && make clean
	@cd cn_secondary_payload && make clean
	@cd oss_cro && make clean
	@cd ro_command_handler && make clean
	@cd ro_initial_code && make clean
	@cd ro_initial_rop && make clean
	@cd spider_code && make clean
	@cd spider_hook_rop && make clean
	@cd spider_initial_rop && make clean
	@cd spider_thread0_rop && make clean
	@echo "all cleaned up !"
