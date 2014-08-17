all: constants.txt

clean:
	@rm -f constants.txt
	@cd 2049 && make clean
	@echo "all cleaned up !"

constants.txt:
	@cd $(ROVERSION) && make
	@cp $(ROVERSION)/$@ ./
