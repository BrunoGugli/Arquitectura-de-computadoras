module top_uart
(
    input wire i_clk,       // System clock from testbench
    input wire i_reset,     // Reset signal from testbench
    input wire i_rx,        // Serial data input from testbench
    output wire o_rx_done,  // Output flag when reception is done
    output wire [7:0] o_data // Output received data
);

    // Signals to connect baud_rate_gen and uart_receiver
    wire baud_tick;

    // Baud rate generator instance
    baud_rate_gen #(
        .clk_freq(50000000),  // 50 MHz clock
        .baud_rate(9600)      // 9600 bps baud rate
    )
    u_baud_rate_gen (
        .i_clk(i_clk),        // Connect to system clock
        .i_reset(i_reset),    // Connect to reset signal
        .i_valid(1'b1),       // Always enable the baud rate generation
        .o_baud_tick(baud_tick)  // Output tick to the receiver
    );

    // UART receiver instance
    uart_receiver #(
        .DATA_BITS(8),        // 8-bit data
        .STP_BITS_TICKS(16)   // 16 ticks for stop bit
    )
    u_uart_receiver (
        .i_clk(i_clk),        // Connect to system clock
        .i_reset(i_reset),    // Connect to reset signal
        .i_rx(i_rx),          // Connect to received data
        .i_bd_tick(baud_tick),// Connect baud tick from baud_rate_gen
        .o_rx_done(o_rx_done),// Output signal when reception is done
        .o_data(o_data)       // Output received data
    );

endmodule
