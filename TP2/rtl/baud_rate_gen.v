module baud_rate_gen
#(
    parameter clk_freq = 50000000, // 50 MHz
    parameter baud_rate = 9600 // 9.6 kbps
)
(
    input wire i_clk,      // system clock
    input wire i_reset,    // system reset
    input wire i_valid,    // signal to enable baud rate generation
    output reg o_baud_tick // tick generated at the baud rate
);

localparam integer divisor = clk_freq / (baud_rate * 16);
reg [31:0] counter; // to count the clock cycles

// Baud rate generation
always @(posedge i_clk) begin

    if (i_reset) begin

        counter <= 0;
        o_baud_tick <= 0;

    end else if (i_valid) begin

        if (counter == divisor - 1) begin

            o_baud_tick <= 1; // Generate tick
            counter <= 0;     // Reset counter

        end else begin

            o_baud_tick <= 0;
            counter <= counter + 1;

        end

    end else begin

        o_baud_tick <= 0;
        counter <= 0;

    end
end

endmodule
