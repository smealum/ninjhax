SCRIPTS = "../scripts"

all: ro_initial_code.bin

clean:
	@rm ro_initial_code.bin
	@echo "all cleaned up !"

%.bin: %.s
	armips $<
