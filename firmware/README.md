# Setting up the code on your Pico Pi

This code runs on circuitpython: https://circuitpython.org/

It was tested with 
"Adafruit CircuitPython 9.1.4 on 2024-09-17; Raspberry Pi Pico with rp2040"


# Placing code on the microcontroller

code.py goes in the root directory. This will be launched on startup. 

## Libraries

We'll need libraries for the display (SSD1306) and sounder(HC-SR04). 
They can be found as part of the Adafruit_CircuitPython_Bundle
https://circuitpython.org/libraries . I tested with the 9.x bundle matching 
my CircuitPython

The entire library won't fit on our microcontroller, so we'll take
just what we need.  

Put the following directories and files into lib on your pico:
 
* adafruit_bus_device/
* adafruit_bitmap_font/
* adafruit_register/
* adafruit_framebuf.mpy
* adafruit_ssd1306.mpy
* font5x8.bin (see above below)

## Font Data

font5x8.bin needs to be in the root directory. It's used by the 
display code to turn pixels into letters.  
It can be found at:
https://github.com/adafruit/Adafruit_CircuitPython_framebuf/tree/main/examples/

## Final Layout

Your filesystem should look something like so:

```
./lib/adafruit_ssd1306.mpy
./lib/adafruit_bus_device/__init__.py
./lib/adafruit_bus_device/spi_device.mpy
./lib/adafruit_bus_device/i2c_device.mpy
./lib/adafruit_framebuf.mpy
./lib/adafruit_register/i2c_bcd_datetime.mpy
./lib/adafruit_register/__init__.py
./lib/adafruit_register/i2c_struct.mpy
./lib/adafruit_register/i2c_bcd_alarm.mpy
./lib/adafruit_register/i2c_struct_array.mpy
./lib/adafruit_register/i2c_bit.mpy
./lib/adafruit_register/i2c_bits.mpy
./lib/adafruit_bitmap_font/ttf.mpy
./lib/adafruit_bitmap_font/glyph_cache.mpy
./lib/adafruit_bitmap_font/pcf.mpy
./lib/adafruit_bitmap_font/bdf.mpy
./lib/adafruit_bitmap_font/__init__.py
./lib/adafruit_bitmap_font/bitmap_font.mpy
./font5x8.bin
./code.py
```