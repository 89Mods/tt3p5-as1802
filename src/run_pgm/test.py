import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_cpu(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    dut.DI.value = 0
    dut.uart_rx.value = 1
    dut.intr.value = 0
    dut._log.info("reset")
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    
    await ClockCycles(dut.clk, 10)

    dut._log.info("BEGIN PROGRAM OUTPUT")
    spi_buff = 0
    spi_counter = 0
    spi_prev_clk = 0
    while dut.Q.value == 0:
        await FallingEdge(dut.clk)
        await RisingEdge(dut.clk)
        if dut.SCLK.value == 1 and spi_prev_clk == 0:
            spi_buff = spi_buff << 1
            spi_buff = spi_buff + dut.DO.value
            spi_counter = spi_counter + 1
            if spi_counter == 8:
                if spi_buff != 0:
                    print(chr(spi_buff), end='', flush=True)
                spi_counter = 0
                spi_buff = 0
        spi_prev_clk = dut.SCLK.value
    dut._log.info("END PROGRAM OUTPUT")
