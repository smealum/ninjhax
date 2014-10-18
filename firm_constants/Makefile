all: constants.txt

clean:
	@rm -f constants.txt
	@cd PRE5 && make clean
	@cd POST5 && make clean
	@cd N3DS && make clean
	@echo "all cleaned up !"

constants.txt:
	@cd $(FIRMVERSION) && make
	@cp $(FIRMVERSION)/$@ ./
