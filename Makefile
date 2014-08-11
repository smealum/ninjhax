SCRIPTS = "scripts"
MKDIR = $(mkdir build && mkdir build/cro)

.PHONY: directories all

all: directories build/spider_thread0_rop.bin
directories:
	@mkdir -p build && mkdir -p build/cro


build/spider_thread0_rop.bin: spider_thread0_rop/spider_thread0_rop.bin
	@cp spider_thread0_rop/spider_thread0_rop.bin build
spider_thread0_rop/spider_thread0_rop.bin: build/oss.cro
	@cd spider_thread0_rop && make


build/oss.cro: oss_cro/out_oss.cro
	@cp oss_cro/out_oss.cro build
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
	rm build/*
	@echo "all cleaned up !"
