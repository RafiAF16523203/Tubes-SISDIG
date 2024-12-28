import serial
import time

# MIDI UART Settings
UART_PORT = "/dev/ttyUSB0"  # Replace with your UART port
BAUD_RATE = 31250

# MIDI Commands
NOTE_ON = 0x90  # Note On command
NOTE_OFF = 0x80  # Note Off command

# Initialize Serial Port
uart = serial.Serial(UART_PORT, BAUD_RATE)

def send_midi_note_on(channel, note, velocity):
    """Send a MIDI Note On message."""
    message = bytes([NOTE_ON | (channel & 0x0F), note, velocity])
    uart.write(message)
    print(f"Sent Note On: Channel={channel}, Note={note}, Velocity={velocity}")

def send_midi_note_off(channel, note, velocity):
    """Send a MIDI Note Off message."""
    message = bytes([NOTE_OFF | (channel & 0x0F), note, velocity])
    uart.write(message)
    print(f"Sent Note Off: Channel={channel}, Note={note}, Velocity={velocity}")

# Example Usage
if __name__ == "__main__":
    try:
        while True:
            send_midi_note_on(channel=0, note=60, velocity=127)  # Middle C
            time.sleep(0.5)
            send_midi_note_off(channel=0, note=60, velocity=127)
            time.sleep(0.5)
    except KeyboardInterrupt:
        print("Exiting...")
        uart.close()
