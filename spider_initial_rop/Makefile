SCRIPTS = "../scripts"

all: spider_initial_rop.bin

clean:
	@rm -f spider_initial_rop.bin
	@echo "all cleaned up !"

%.bin: %.s
	armips $<
