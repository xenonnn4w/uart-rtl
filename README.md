# UART Transmitter

Parameterized Verilog UART transmitter with an 8N1 frame format and a self-checking SystemVerilog testbench.

## Features

- Eight data bits, LSB first, one start bit and one stop bit.
- Configurable clock and baud rate.
- Busy flag, one-cycle completion pulse, and synchronous reset.
- Input data is latched at the start; requests while busy are ignored.

Inputs must be synchronous to the clock. `CLK_HZ / BAUD` must be an exact integer of at least 2. Holding `start` high starts another frame when idle. Reset aborts the active frame.

## Run

Requires Icarus Verilog 12 or compatible.

```sh
make test
make wave
```

`make wave` generates `build/uart_tx.vcd` for viewing in GTKWave.

## Tests

The testbench checks all 256 byte values at 2, 3, 10, and 16 clocks per bit, including bit timing, busy handling, completion, and reset recovery. Failures return a nonzero exit status.

## Files

- `rtl/uart_tx.v` — transmitter RTL.
- `tb/uart_tx_tb.sv` — self-checking testbench.
- `Makefile` — simulation and waveform commands.

Simulation only; not validated on FPGA hardware.
