SCRIPTS = "../scripts"

all: ro_initial_rop.bin

clean:
	@rm ro_initial_rop.bin
	@echo "all cleaned up !"

%.bin: %.s
	armips $<
