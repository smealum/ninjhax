SCRIPTS = "../scripts"

all: spider_code.bin

clean:
	@rm spider_code.bin
	@echo "all cleaned up !"

%.bin: %.s
	armips $<
