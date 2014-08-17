all: constants.txt

clean:
	@rm -f constants.txt
	@cd WEST && make clean
	@echo "all cleaned up !"

constants.txt:
	@cd $(CNVERSION) && make
	@cp $(CNVERSION)/$@ ./
