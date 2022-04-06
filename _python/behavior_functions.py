# -*- coding: utf-8 -*-
"""
Created on Wed Apr  6 11:12:12 2022

@author: Kath
"""

def loadArduinoSketch(comport,sketchPath):
    import os
    from subprocess import run
    cmdIn = sprintf('%s%s%s%s:i"','cmd /C ""C:\\Program Files (x86)\\Arduino\\hardware\\tools\\avr\\bin\\avrdude.exe" -C"C:\\Program Files (x86)\\Arduino\\hardware\\tools\\avr/etc/avrdude.conf" -v -patmega328p -carduino -P',comport,' -b115200 -D -Uflash:w:',sketchPath);
    cmdIn = '%s%s%s%s:i"' % ('cmd /C ""C:\\Program Files (x86)\\Arduino\\hardware\\tools\\avr\\bin\\avrdude.exe" -C"C:\\Program Files (x86)\\Arduino\\hardware\\tools\\avr/etc/avrdude.conf" -v -patmega328p -carduino -P',comport,' -b115200 -D -Uflash:w:',sketchPath)
    
    
    
    cmdIn = '%s%s%s%s:i"' % ('""C:\\Program Files\\WindowsApps\\ArduinoLLC.ArduinoIDE_1.8.57.0_x86__mdqgnx93n4wtt\\hardware\\tools\\avr/bin/avrdude.exe" -C"C:\\Program Files\\WindowsApps\\ArduinoLLC.ArduinoIDE_1.8.57.0_x86__mdqgnx93n4wtt\\hardware\\tools\\avr/etc/avrdude.conf" -v -patmega328p -carduino -P',comport,' -b115200 -D -Uflash:w:',sketchPath)

    avrdude = "C:\\Program Files\\WindowsApps\\ArduinoLLC.ArduinoIDE_1.8.57.0_x86__mdqgnx93n4wtt\\hardware\\tools\\avr/bin/avrdude"
    avrdude_conf = "-CC:\\Program Files\\WindowsApps\\ArduinoLLC.ArduinoIDE_1.8.57.0_x86__mdqgnx93n4wtt\\hardware\\tools\\avr/etc/avrdude.conf"
    sketchPath = 'C:\\Users\\Kath\\AppData\\Local\\Temp\\arduino_build_598991/2afc_freeMoving_photoDetectors.ino.hex'
    sketchPath_ = "Uflash:w:%s" % (sketchPath)
    cmdIn = '%s%s%s%s:i"' % ('cmd /C ""C:\Program Files\WindowsApps\ArduinoLLC.ArduinoIDE_1.8.57.0_x86__mdqgnx93n4wtt\hardware\tools\avr/bin/avrdude" -C"C:\Program Files\WindowsApps\ArduinoLLC.ArduinoIDE_1.8.57.0_x86__mdqgnx93n4wtt\hardware\tools\avr/etc/avrdude.conf" -v -patmega328p -carduino -P',comport,' -b115200 -D -Uflash:w:',sketchPath)
    os.system(cmdIn)