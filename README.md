ninjhax
=======

ninjhax is a piece of software that allows you to run unsigned code on your 3DS. In practice, this means being able to run homebrew applications such as games, tools and emulators.

You can find more information on how to use ninjhax at the following address : http://smealum.net/ninjhax/

You can also find a detailed technical writeup about how ninjhax works here : http://smealum.net/?p=517

**DISCLAIMER** : most of the code on this repo is super dirty. it was made in a rush to work somewhat reliably rather than be maintainable and well thought out. Please keep that in mind and know that none of this should be taken as an example of good practices.

### Building ninjhax

First, you will need to satisfy some software dependencies :
- armips (which can be found here : https://github.com/Kingcom/armips)
- devkitArm (which can be found here : http://devkitpro.org/)
- an old version of ctrulib, as the latest version will NOT work (this revision should do : https://github.com/smealum/ctrulib/tree/c4382042d633168019137580aaa5bef1eaa7d103 ; make sure you set your CTRULIB environment variable to point to this old version of ctrulib)
- python (3 is recommended, 2 will probably work)

Secondly, you will need to procure files required for building the executable. These files are not my IP so I can not (and will not) distribute them. Note that none of the data from these files ends up in the final product, we only use them to generate patches with our own data. You will need all versions of spider/SKATER's oss.cro file (found in romfs) :

	oss_cro/2050/oss.cro
	oss_cro/3074/oss.cro
	oss_cro/4096/oss.cro
	oss_cro/SKATER_10/oss.cro
	
You will also need the processed blowfish key data for qr code crypto. It can be extracted from a ramdump or generated from exefs data :

	scripts/blowfish_processed.bin

That done, building is very easy. Open a terminal, cd to the ninjhax directory, and :

- To build ninjhax for a single specific firmware version, use (replace "7.1.0-16E" with firmware version) : `python scripts/buildVersion.py "7.1.0-16E"`
- To build all versions : `python scripts/buildAll.py`

There are a lot of firmware versions out there, so building them all may take a while (think 10~20 minutes).

### Description of modules

The ninjhax source code is divided into a number of different modules. Some names are fairly straightforward, others are not. Here's an individual description of each module (roughly in order of execution where applicable) :
 
- **cn_qr_initial_loader** : qr code that ROPs its way to gspwn, gets code exec, downloads cn_secondary_payload through HTTP and launches it
- **cn_save_initial_loader** : modified savegame file that loads cn_secondary_payload from save and launches it
- **cn_secondary_payload** : finishes cn cleanup, takes over spider with spider_initial_rop, then waits for it to return. subsequently sets up bootloader through HB command and uses it to launch hb_menu (boot.3dsx)
- **spider_hook_rop** : takes over spider thread5
- **spider_initial_rop** : takes over spider thread0 from thread5
- **spider_thread0_rop** : takes over ro with rohax and then jumps to spider_code
- **ro_initial_rop** : gets code exec in ro and jumps to code
- **ro_initial_code** : reprotects spider mem and returns to spider
- **ro_command_handler** : handles HB service commands
- **spider_code** : does spider cleanup, returns handles to cn
- **cn_bootloader** : calls HB command to load homebrew, then flushes/invalidates cache and jumps to app code
- **firm_constants** : contains constants relevant to FIRM
- **cn_constants** : contains constants relevant to cubic ninja
- **spider_constants** : contains constants relevant to spider/SKATER
- **ro_constants** : contains constants relevant to ro
- **scripts** : contains various scripts used in the build process
- **oss_cro** : contains all versions of oss.cro used in the build process

### Known issues

Sometimes generated QR codes won't be recognized by cubic ninja. This is almost certainly a padding issue and I've never looked into fixing it. Simply rebuilding usually fixes it (because of random data changing).

### Credits

 - smea — 3DS research, core exploit code for all versions, ctrulib improvements, hbmenu code, testing/debugging 
 - yellows8 — 3DS research, ctrulib improvements, auditing, help with pretty much everything 
 - plutoo — 3DS research, ctrulib improvements, auditing, help with pretty much everything 
 - fincs — 3DSX format/code, ctrulib improvements, devkitARM integration, testing 
 - mtheall — ctrulib improvements, hbmenu code, testing, .gitignore files
 - GEMISIS — hbmenu code, testing 
 - Fluto, Arkhandar — hbmenu design 
 - Normmatt, ichfly — general help, testing 
 - case — javascript master 
 - lobo — webpage template 
