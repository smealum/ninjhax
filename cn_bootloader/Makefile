SCRIPTS = "../scripts"

all: cn_bootloader.bin

clean:
	@rm -f cn_bootloader.bin
	@echo "all cleaned up !"

%.bin: %.s
	armips $<
