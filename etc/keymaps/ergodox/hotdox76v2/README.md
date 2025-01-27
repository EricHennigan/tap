

0. Prepare a python virtual environment
   `virtualenv venv`
   `source venv/bin/activate`

   setup the qmk command line
   `python3 -m pip install qmk`
   `qmk setup`

   - installs some usb rules
   - creates a directory ~/qmk\_firmware 

1. Apply the diff to qmk\_firmware
2. Add the file keyboards/hotdox76v2/rules.mk
3. Add the file keyboards/hotdox76v2/keymaps/via/keymap.c
4. Flash with command
   qmk flash -kb hotdox76v2 -km via

Note, the big trouble here is that the online qmk configurator does not
 - allow control over the default backlight (rgb\_matrix) setting
 - puts the keys in the WRONG ORDER in the generated keymap.c file

