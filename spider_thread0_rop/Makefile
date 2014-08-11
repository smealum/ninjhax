SCRIPTS = "../scripts"

all: spider_thread0_rop.bin

clean:
	@rm spider_thread0_rop.bin
	@echo "all cleaned up !"

%.bin: %.s
	armips $<
