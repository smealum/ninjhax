all: constants.txt

clean:
	@rm -f constants.txt
	@cd OLD_MEMMAP && make clean
	@cd NEW_MEMMAP && make clean
	@echo "all cleaned up !"

constants.txt:
	@cd $(FIRMVERSION) && make
	@cp $(FIRMVERSION)/$@ ./
