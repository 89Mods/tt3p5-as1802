`default_nettype none
`timescale 1ns/1ps
`define SIM

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
	// testbench is controlled by test.py
	input clk,
	input rst_n,
	input intr,
	input uart_rx,
	
	input [3:0] EF,
	
	output Q,
	output uart_tx
);

	// this part dumps the trace to a vcd file that can be viewed with GTKWave
	initial begin
		$dumpfile ("tb.vcd");
		$dumpvars (0, tb);
		#1;
	end
	
	wire IO0;
	wire IO1;
	wire IO2;
	wire IO3;

	// wire up the inputs and outputs
	wire [7:0] uo_out;
	wire [7:0] uio_out;
	wire [7:0] uio_oe;
	assign Q = uo_out[0];
	wire CS_ROM = uo_out[1];
	wire SCLK = uo_out[2];
	
	wire [3:0] QSPI_DO = uio_out[3:0];
	wire [3:0] QSPI_OEB = uio_oe[3:0];
	assign IO0 = QSPI_OEB[0] ? 1'bz : QSPI_DO[0];
	assign IO1 = QSPI_OEB[1] ? 1'bz : QSPI_DO[1];
	assign IO2 = QSPI_OEB[2] ? 1'bz : QSPI_DO[2];
	assign IO3 = QSPI_OEB[3] ? 1'bz : QSPI_DO[3];
	
	assign uart_tx = uo_out[4];
	
	// instantiate the DUT
	tt_um_as1802 as1802(
		`ifdef GL_TEST
			.vccd1( 1'b1),
			.vssd1( 1'b0),
		`endif
		.ena  (1'b1),
		.clk (clk),
		.rst_n(rst_n),
		.ui_in({2'b00, uart_rx, intr, EF}),
		.uo_out(uo_out),
		.uio_in({4'b0000, IO3, IO2, IO1, IO0}),
		.uio_out(uio_out),
		.uio_oe(uio_oe)
		);
		
	W25Q128JVxIM W25Q128JVxIM(
		.CSn(CS_ROM),
		.CLK(SCLK),
		.DIO(IO0),
		.DO(IO1),
		.WPn(IO2),
		.HOLDn(IO3)
	);

endmodule
