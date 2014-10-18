all: constants.txt

clean:
	@rm -f constants.txt
	@cd 2050 && make clean
	@cd 3074 && make clean
	@cd 4096 && make clean
	@cd SKATER_10 && make clean
	@echo "all cleaned up !"

constants.txt:
	@cd $(SPIDERVERSION) && make
	@cp $(SPIDERVERSION)/$@ ./
