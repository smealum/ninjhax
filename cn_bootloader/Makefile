SCRIPTS = "../scripts"

all: cn_bootloader.bin

clean:
	@rm cn_bootloader.bin
	@echo "all cleaned up !"

%.bin: %.s
	armips $<
