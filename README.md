# CompArchGBADemo
A simple game made as a demo for a presentation on the Gameboy Advance's architecture. Basketballs are thrown from the bottom-left of the screen, and the goal is to catch them by moving the hoop. You can move the hoop using the D-pad.

To play the demo for yourself, check under the "Releases" tab and download the latest ROM (Demo.gba). You will need either an emulator or some way to get the ROM onto a cartridge.

# Compiling
This demo was built using DevKitARM. To compile, you must use the following commands:

arm-none-eabi-gcc -mthumb-interwork -specs=gba.specs main.s  
arm-none-eabi-objcopy -O binary a.out Demo.gba

This will generate a ROM file called "Demo.gba". Currently, the project does not use makefiles, and simply includes all other assembly source files from within main.s.
