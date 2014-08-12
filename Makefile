SCRIPTS = "scripts"

.PHONY: directories all cn_qr_initial_loader/cn_qr_initial_loader.bin.png cn_secondary_payload/cn_secondary_payload.bin cn_bootloader/cn_bootloader.bin spider_initial_rop/spider_initial_rop.bin spider_thread0_rop/spider_thread0_rop.bin oss_cro/out_oss.cro build/ro_initial_code.bin build/ro_initial_rop.bin build/spider_code.bin

all: directories build/cn_qr_initial_loader.bin.png build/cn_secondary_payload.bin
	@cp build/cn_qr_initial_loader.bin.png ./
	@cp build/cn_secondary_payload.bin ./
directories:
	@mkdir -p build && mkdir -p build/cro


build/cn_qr_initial_loader.bin.png: cn_qr_initial_loader/cn_qr_initial_loader.bin.png
	@cp cn_qr_initial_loader/cn_qr_initial_loader.bin.png build
cn_qr_initial_loader/cn_qr_initial_loader.bin.png:
	@cd cn_qr_initial_loader && make


build/cn_secondary_payload.bin: cn_secondary_payload/cn_secondary_payload.bin
	@cp cn_secondary_payload/cn_secondary_payload.bin build
cn_secondary_payload/cn_secondary_payload.bin: build/spider_initial_rop.bin build/spider_thread0_rop.bin build/cn_bootloader.bin
	@cp build/spider_initial_rop.bin cn_secondary_payload/data
	@cp build/spider_thread0_rop.bin cn_secondary_payload/data
	@cp build/cn_bootloader.bin cn_secondary_payload/data
	@cd cn_secondary_payload && make


build/cn_bootloader.bin: cn_bootloader/cn_bootloader.bin
	@cp cn_bootloader/cn_bootloader.bin build
cn_bootloader/cn_bootloader.bin:
	@cd cn_bootloader && make


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
	@python $(SCRIPTS)/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch0.bin 0x0 0x60
	@python $(SCRIPTS)/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch700.bin 0x700
	@python $(SCRIPTS)/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch2000.bin 0x2000
	@python $(SCRIPTS)/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch1D9020.bin 0x1D9020
	@python $(SCRIPTS)/extractPatch.py oss_cro/oss.cro oss_cro/out_oss.cro build/cro/patch1DBA90.bin 0x1DBA90
	@python $(SCRIPTS)/fixCRRpatch.py build/out_oss.cro build/cro/patchCRR.bin
oss_cro/out_oss.cro: build/ro_initial_rop.bin build/ro_initial_code.bin build/spider_code.bin
	@cd oss_cro && make 


build/ro_initial_rop.bin: ro_initial_rop/ro_initial_rop.bin
	@cp ro_initial_rop/ro_initial_rop.bin build
ro_initial_rop/ro_initial_rop.bin:
	@cd ro_initial_rop && make


build/ro_initial_code.bin: ro_initial_code/ro_initial_code.bin
	@cp ro_initial_code/ro_initial_code.bin build
ro_initial_code/ro_initial_code.bin:
	@cd ro_initial_code && make


build/spider_code.bin: spider_code/spider_code.bin
	@cp spider_code/spider_code.bin build
spider_code/spider_code.bin:
	@cd spider_code && make


clean:
	@rm -rf build/*
	@cd cn_bootloader && make clean
	@cd cn_qr_initial_loader && make clean
	# @cd cn_save_initial_loader && make clean
	@cd cn_secondary_payload && make clean
	@cd oss_cro && make clean
	@cd ro_command_handler && make clean
	@cd ro_initial_code && make clean
	@cd ro_initial_rop && make clean
	@cd spider_code && make clean
	@cd spider_initial_rop && make clean
	@cd spider_thread0_rop && make clean
	@echo "all cleaned up !"
