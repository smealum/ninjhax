all: constants.txt

clean:
	@rm -f constants.txt
	@cd 4096 && make clean
	@echo "all cleaned up !"

constants.txt:
	@cd $(SPIDERVERSION) && make
	@cp $(SPIDERVERSION)/$@ ./
