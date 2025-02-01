# measure and display distances
#  inspired by
#  https://circuitdigest.com/microcontroller-projects/interfacing-raspberry-pi-pico-w-with-ultrasonic-sensor

import digitalio
import time
import board
import gc

import busio
import adafruit_ssd1306

# time to cm, assumption about speed of sound in air.
CM_PER_NS = 34.3/1_000_000

USEC_15 = 15.0/1_000_000
NS_IN_70_MS = 70_000_000
NS_PER_SEC = 1_000_000_000

DISP_ON = 0xAF # display.poweron()
DISP_OFF = 0xAE #display.poweroff()

# For some reason, docstrings show up in the output of Thonny, so we end up with comments
# about the functions :(

# turn the time the echo was high into a measurement. Returns in integer number of centimeters
def to_cm(ns):
    # we divide by two because of the back and forth path the signal takes.
    return int(((ns * CM_PER_NS) /2)+0.5)

# print the distance traveled when echo was high for ns
def print_time(ns):
    distance = (ns * CM_PER_NS) /2 # /2 coming and going
    print(f"distance is {distance} cm over {ns} nseconds")


# set up the display and return it. While the board is 128x64, we initialize 128x32
# to make things more readable. If we need more space we can reconsider. Uses i2c on GP4.
# SSD1306 OLED driver IC.
def make_display():
    i2c = busio.I2C(board.GP5, board.GP4)
    display_width = 128
    display_height = 32 #64 actually, but 32 makes the display characters easier to read
    display = adafruit_ssd1306.SSD1306_I2C(display_width, display_height, i2c)
    return display

# set up the HC-SR04 ultrasonic sensor. Returns a tuple (trigger input, echo output).
# uses gpio 12 and 13. Raise trigger for at least 10us to initialize a measurement.
# some point after triggering the echo will go high (eH), and then low(eL).
# The time between eH and eL tells us the measurement made by the sensor. """
def make_sounder():
    trigger = digitalio.DigitalInOut(board.GP13)
    echo = digitalio.DigitalInOut(board.GP12)
    trigger.switch_to_output()
    echo.switch_to_input()
    return trigger, echo

#create two buttons that can be read. Creates two button that will be True
# if the switch is in the closed position. Uses GP8, GP9, GP21, and GP22.
# If the screen is at the top of the box returns  (left, right) buttons.
def make_display_buttons():
    enter_key_in = digitalio.DigitalInOut(board.GP21)
    enter_key_in.pull = digitalio.Pull.DOWN
    enter_key_out = digitalio.DigitalInOut(board.GP22)
    enter_key_out.switch_to_output()
    enter_key_out.value = True

    mode_key_in = digitalio.DigitalInOut(board.GP8)
    mode_key_in.pull = digitalio.Pull.DOWN
    mode_key_out = digitalio.DigitalInOut(board.GP9)
    mode_key_out.switch_to_output()
    mode_key_out.value = True
    return mode_key_in, enter_key_in


# Sounder encapsulates the display/led/button/sounder interactions
class Sounder:
    def __init__(self):
        # the OLED display
        self.display = make_display()

        # we need to not trigger the sounder faster than every 60ms, this
        # keep track of the last time we sent a 'ping,', in nanoseconds
        self.last_trigger_ns = 0

        # sounder input and output
        self.trigger, self.echo = make_sounder()

        # used to count down when doing measurements
        self.led = digitalio.DigitalInOut(board.GP18)
        self.led.switch_to_output()

        self.mode, self.enter = make_display_buttons()

    #Tell the sounder to send a ping.
    # We need to wait 60ms between pulses to avoid false responses due to echo.
    # We will wait 70ms as I've had issues. However, we can make use of the work done
    # between now and the last effort, so we don't wait a complete 70ms here, but rather
    # only wait until it's been 70ms from the last ping.
    def trigger_ping(self):
        self.trigger.value = False
        diff_ns = NS_IN_70_MS - (time.monotonic_ns() - self.last_trigger_ns)
        # if it's <= 0 there's no need to wait
        if diff_ns > 0 :
            # sleep is in seconds, but we have ns
            time.sleep(diff_ns / NS_PER_SEC)
        self.last_trigger_ns = time.monotonic_ns()

        # trigger a measurement
        self.trigger.value = True
        # trigger needs to be on for at least 10us
        time.sleep(USEC_15)
        self.trigger.value = False

    # measure one distance, returning time in ns between send and receive. May wait up to ~70ms
    # to ensure  the ping doesn't receive an echo.
    def measure_once(self):
        # duration of echo response is how far echo traveled, so we measure its width
        self.trigger_ping()

        # if the garbage collector runs while we're waiting for the echo to go up, we may
        # never see the signal go up and if the signal goes down before collection completes we'll
        # wait here forever. Disabling the GC while we spin avoids the issue
        gc.disable()

        # we want to know when the signal went high, we busy wait, updating signaloff each time.
        # when the signal goes high we'll have the last time it wasn't as the start of the high value.
        echo_on = 0
        echo_off = 0
        while not self.echo.value:
            echo_on = time.monotonic_ns()
        # now we wait for it to fall, updating until it stops.
        while self.echo.value:
            echo_off = time.monotonic_ns()

        # we've got the measurements we need, so can collect again.
        gc.enable()
        # we need to force a collection. If we let it do its own thing I ended up running
        # out of memory when measuring in a tight loop. It's no big performance problem,
        # since we need to wait 60ms between pings anyway, might as well spend some of that time
        # collecting garbage
        gc.collect()
        return echo_off - echo_on

    # display the given txt on the screen. txt needs to be formatted so it doesn't
    # go off the edgs. nums can be a list of numbers. If given it will put up a small,
    # axis-less graph to show how the measurements in numbs changed over time."""
    def display_msg(self, txt, nums=None):
        self.display.fill(0)
        self.display.text(txt, 0,0,1)
        if nums:
            mn = min(nums)
            mx = max(nums)
            # we want our graph to be 10 pixels high, so we scale per_pxl to fix the biggest
            # difference to be exactly 10 apart
            diff = mx-mn
            per_pxl = diff/10
            for i,m in enumerate(nums):
                x = 10+(2*i)
                y = 31-int((m-mn)/per_pxl)
                # 1 pixel is too small, we'll use 4 per point
                self.display.pixel(x,y, 1)
                self.display.pixel(x+1,y, 1)
                self.display.pixel(x,y-1, 1)
                self.display.pixel(x+1,y-1, 1)
                #print(f" setting {x},{y}")
        self.display.show()

    # count down n seconds, with LED flashes. Returns when countdown is complete. Flashed the LED more
    # slowly as the countdown gets closer to 0.
    def countdown(self, n=5):
        self.display.write_cmd(DISP_ON)
        # we'll start blinking fast, and slow as we get closer to zero
        blinks = 2*n+1
        for x in range(n):
            d = n-x
            self.display_msg(f"Measuring in\n  {d}sec")
            for _ in range(blinks):
                time.sleep(1.0/blinks)
                # toggle the value with XOR
                self.led.value ^= True
            blinks -= 2 # change the rate so it blinks more slowly as time goes on
        self.display_msg("Measuring now")
    

    # measure n times as quickly as possible. returns a list of measurements, in cms
    def do_many(self, n=5):
        self.countdown()
        self.led.value = True
        self.display.auto_refresh = False  # do we need this?
        start = time.monotonic_ns()

        res = [None] * n
        for i in range(n):
            res[i] = self.measure_once()

        endt = time.monotonic_ns()
        self.display.auto_refresh = True  # do we need this?
        # indicate we're done measuring by turning off the LED
        self.led.value = False

        print(f"{n} runs took {int((endt-start)/1000000)}ms")
        mn = to_cm(min(res))
        mx =  to_cm(max(res))
        self.display_msg(f"min:{mn}cm  max:{mx}cm\npress key to restart", [to_cm(x) for x in res])
        return res

    # wait for a press of either mode or enter. Returns self.mode or self.enter, depending on which was pressed
    def wait_for_press(self):
        mode = self.mode.value
        enter = self.enter.value
        # spin waiting for a press
        while not mode and not enter:
            time.sleep(USEC_15)
            mode = self.mode.value
            enter = self.enter.value
        if mode:
            return self.mode
        return self.enter

    def run(self):
        line_one = "*"
        line_two = " "
        while True:
            k = self.mode
            while k == self.mode:
                self.display_msg(f"left:DOWN. Right:GO\n{line_one} measure many\n{line_two} measure one\n")
                k = self.wait_for_press()
                if k == self.mode:
                    line_one, line_two = line_two, line_one
            if line_one == "*":
                self.do_many(n=50)
            elif line_two == "*":
                cm = to_cm(self.measure_once())
                self.display_msg(f"measures: {cm}cm\nAny key to continue\n")
            self.wait_for_press()

sounder = Sounder()
sounder.run()