SCRIPTS = "../scripts"

all: ro_initial_rop.bin

clean:
	@rm -f ro_initial_rop.bin
	@echo "all cleaned up !"

%.bin: %.s
	armips $<
