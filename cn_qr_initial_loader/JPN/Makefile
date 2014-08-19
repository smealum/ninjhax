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
NAME = cn_qr_initial_loader

.PHONY: all cn_initial/cn_initial.bin

all: $(NAME).bin.png

%.bin.png: %.bin
	@python $(SCRIPTS)/obfuscator5000.py $<
	@python $(SCRIPTS)/crypt.py $< $(SCRIPTS)
	@$(SCRIPTS)/qrcode.exe -8 -o $@ < tmp
	@rm tmp

clean:
	@cd cn_initial && make clean
	@rm -f $(NAME).bin $(NAME).bin.png
	@echo "all cleaned up !"

-include $(DFILES)

$(NAME).bin: sploit_proto.bin sploit.s cn_initial/cn_initial.bin
	armips sploit.s

cn_initial/cn_initial.bin:
	# probably a bad idea; dependencies won't work well i guess
	$(MAKE) -C cn_initial
