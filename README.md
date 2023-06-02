![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)

# AS1802 for TinyTapeout 3.5

A microcontrolled based on the AS1802 core I developed for [TMBoC](https://github.com/AvalonSemiconductors/TMBoC), but using Q-SPI memories for RAM and ROM. Also has 128 bytes of on-chip RAM, so wiring up external RAM is not required.

For ROM, please use a W25Q-series chip (recommended W25Q32). For RAM, only the LY68L6400 is supported.

I/O consists of one UART, one general-purpose SPI port, 4 input ports and one output port. For more I/O, the SPI bus may be used.

## Memory Map

The AS1802 has an address range of 64KiB. Addresses 0000h - 7FFFh are mapped to the first 32KiB of ROM. 8000h - 80FFh map to internal RAM, 8100h - FFEFh to external RAM. I/O devices are memory-mapped to FFF0h - FFFFh.

See this table for a list of memory-mapped IOs:

| Address | Function (read) | Function (write) |
| ------- | --------------- | ---------------- |
| FFF0h   | UART clock div (low byte) | UART clock div (low byte) |
| FFF1h   | UART clock div (high byte) | UART clock div (high byte) |
| FFF2h   | UART receive buffer | UART send buffer |
| FFF3h   | SPI and UART status | RAM dummy cycle count |
| FFF4h   | SPI receive buffer | SPI clock div |
| FFF5h   | 0 | SPI send buffer |

Unused I/O locations FFF6h - FFFFh will return 0 when read, and have no effect when written.

## Note on external RAM interface

The LY68L6400 requires a series of dummy cycles between address and data on reads. However, the amount of dummy cycles required may change depending on CPU clock speed, so the length of this delay is configurable by writing to IO location FFF3h (TODO: test if this is actually the case).

## Test program

The following short test program will blink the Q output.

```
START: org 0
	DIS
	db 0
	LDI 0
CLEAR:
	REQ
DELAY:
	NOP
	NOP
	NOP
	NOP
	ADI 1
	BNDF DELAY
	BQ CLEAR
	LDI 0
	SEQ
	BR DELAY
```
