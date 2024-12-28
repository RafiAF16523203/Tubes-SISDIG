import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

# MIDI Constants
MIDI_NOTE_ON = 0x90  # Note On command
MIDI_NOTE_OFF = 0x80  # Note Off command

@cocotb.test()
async def uart_midi_test(dut):
    """Test UART Transmitter and Receiver with MIDI messages."""
    # Create a clock with a 16 MHz frequency (62.5 ns period)
    cocotb.fork(Clock(dut.clk, 62.5, units="ns").start())

    # Reset the DUT
    dut.rst <= 1
    await Timer(100, units="ns")
    dut.rst <= 0

    # Define a MIDI message: Note On, Channel 0, Middle C (60), Velocity 127
    midi_message = [MIDI_NOTE_ON, 60, 127]

    # Send the MIDI message byte by byte
    for byte in midi_message:
        # Wait until the transmitter is not busy
        while dut.tx_start.value != 0:
            await RisingEdge(dut.clk)

        # Send the byte
        dut.tx_data <= byte
        dut.tx_start <= 1
        await RisingEdge(dut.clk)
        dut.tx_start <= 0

    # Wait for the receiver to process the bytes
    for expected_byte in midi_message:
        while dut.rx_ready.value == 0:
            await RisingEdge(dut.clk)

        # Check the received data
        received_byte = dut.rx_data.value.integer
        assert received_byte == expected_byte, f"Expected {expected_byte}, got {received_byte}"

        # Acknowledge data reception
        await RisingEdge(dut.clk)

    cocotb.log.info("All MIDI bytes transmitted and received correctly!")
