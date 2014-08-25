ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

ifeq ($(strip $(CTRULIB)),)
$(error "Please set CTRULIB in your environment. export DEVKITARM=<path to>ctrulib/libctru")
endif

ifeq ($(filter $(DEVKITARM)/bin,$(PATH)),)
export PATH:=$(DEVKITARM)/bin:$(PATH)
endif

SCRIPTS = "../../scripts"
NAME = cn_save_initial_loader

.PHONY: all cn_initial/cn_initial.bin

all: $(NAME).bin

clean:
	@cd cn_initial && make clean
	@rm -f $(NAME).bin $(NAME).bin.png
	@echo "all cleaned up !"

-include $(DFILES)

$(NAME).bin: sploit_proto.bin sploit.s cn_initial/cn_initial.bin
	@armips sploit.s
	@python $(SCRIPTS)/obfuscator5000.py $<

cn_initial/cn_initial.bin:
	$(MAKE) -C cn_initial
