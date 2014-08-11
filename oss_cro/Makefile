SCRIPTS = "../scripts"

.PHONY: oss_new.cro

oss_new.cro: oss.cro
	@python $(SCRIPTS)/makeROP.py ../build/ro_initial_rop.bin oss.cro out_oss.cro
	@armips oss.s
	@python $(SCRIPTS)/fixCRO.py out_oss.cro

clean:
	rm build/*
	@echo "all cleaned up !"
