ninjhax
=======

to build :

	download and build armips, copy to PATH

	setup CTRULIB env to point to libctru dir
	setup DEVKITARM env to point to devkitARM dir

	for a single specific version :
		python scripts/buildVersion.py "7.1.0-16E"
	for ALL versions :
		python scripts/buildAll.py


extra files required to make :

	scripts/blowfish_processed.bin
	oss_cro/2050/oss.cro
	oss_cro/3074/oss.cro
	oss_cro/4096/oss.cro


description of files :
 
	cn_qr_initial_loader
		qr code that ROPs its way to gspwn, gets code exec, downloads cn_secondary_payload through HTTP and launches it
	cn_save_initial_loader
		modified savegame file that loads cn_secondary_payload from save and launches it
 
	cn_secondary_payload
		finishes cn cleanup, takes over spider with spider_initial_rop, then waits for it to return, sets up bootloader through HB command and uses it to launch hb_menu
 
	spider_initial_rop
		takes over spider thread0
	spider_thread0_rop
		takes over ro and jumps to code
 
	ro_initial_rop
		gets code exec in ro and jumps to code
	ro_initial_code
		reprotects spider mem and returns to spider
	ro_command_handler
		handles HB service commands
 
	spider_code
		does spider cleanup, returns handles to cn
 
	cn_bootloader
		calls HB command to load homebrew, then flushes/invalidates cache and jumps to app code
 
	installer
		installs the exploit to the savegame

	hb_menu
		lists homebrew apps on SD and uses bootloader to start them
