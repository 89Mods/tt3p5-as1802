`default_nettype none

module seven_segment_seconds #( parameter MAX_COUNT = 1000 ) (
  input [7:0] ui_in,
  output [7:0] uo_out,
  input [7:0] uio_in,
  output [7:0] uio_out,
  output [7:0] uio_oe,
  input ena,
  input clk,
  input rst_n
);
    
    wire [6:0] led_out;
    assign uo_out[6:0] = led_out;
    assign uio_oe = 8'hFF;
    assign uio_out = 8'hFF;

    // slow clock out on the last gpio
    assign uo_out[7] = second_counter[4];

    // external clock is 1000Hz, so need 10 bit counter
    reg [9:0] second_counter;
    reg [3:0] digit;

    always @(posedge clk) begin
        // if reset, set counter to 0
        if (!rst_n) begin
            second_counter <= 0;
            digit <= 0;
        end else begin
            // if up to 16e6
            if (second_counter == MAX_COUNT) begin
                // reset
                second_counter <= 0;

                // increment digit
                digit <= digit + 1'b1;

                // only count from 0 to 9
                if (digit == 9)
                    digit <= 0;

            end else
                // increment counter
                second_counter <= second_counter + 1'b1;
        end
    end

    // instantiate segment display
    seg7 seg7(.counter(digit), .segments(led_out));

endmodule
