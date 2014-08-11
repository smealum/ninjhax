SCRIPTS = "../scripts"

all: sploit_map.bin.png

%.bin.png: %.bin
	@python $(SCRIPTS)/crypt.py $< $(SCRIPTS)
	@$(SCRIPTS)/qrcode.exe -8 -o $@ < tmp
	@rm tmp

clean:
	@cd cn_initial && make clean
	@rm sploit_map.bin sploit_map.bin.png
	@echo "all cleaned up !"

-include $(DFILES)

sploit_map.bin: sploit_proto.bin sploit.s cn_initial/cn_initial.bin
	armips sploit.s

cn_initial/cn_initial.bin:
	# probably a bad idea; dependencies won't work well i guess
	$(MAKE) -C cn_initial
