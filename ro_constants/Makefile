all: constants.txt

clean:
	@rm -f constants.txt
	@cd 1024 && make clean
	@cd 2049 && make clean
	@cd 3074 && make clean
	@cd 4096 && make clean
	@echo "all cleaned up !"

constants.txt:
	@cd $(ROVERSION) && make
	@cp $(ROVERSION)/$@ ./
