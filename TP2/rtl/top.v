module top_uart
(
    input wire i_clk,       // System clock from testbench
    input wire i_reset,     // Reset signal from testbench
    input wire i_rx,        // Serial data input from testbench
    output wire o_rx_done,  // Output flag when reception is done
    output wire [9:0] o_data // Output received data (now 10 bits)
);

    // Signals to connect baud_rate_gen and uart_receiver
    wire baud_tick;
    wire [9:0] full_data;          // Full 10-bit data received from UART
    wire full_data_ready;          // Signal when full 10-bit data is ready

    // Baud rate generator instance
    baud_rate_gen #(
        .clk_freq(50000000),      // 50 MHz clock
        .baud_rate(9600)          // 9600 bps baud rate
    )
    u_baud_rate_gen (
        .i_clk(i_clk),            // Connect to system clock
        .i_reset(i_reset),        // Connect to reset signal
        .i_valid(1'b1),           // Always enable the baud rate generation
        .o_baud_tick(baud_tick)   // Output tick to the receiver
    );

    // UART receiver instance configured for 10-bit data
    uart_receiver #(
        .DATA_BITS(10),           // 10-bit data
        .STP_BITS_TICKS(16)       // 16 ticks for stop bit
    )
    u_uart_receiver (
        .i_clk(i_clk),            // Connect to system clock
        .i_reset(i_reset),        // Connect to reset signal
        .i_rx(i_rx),              // Connect to received data
        .i_bd_tick(baud_tick),    // Connect baud tick from baud_rate_gen
        .o_rx_done(full_data_ready), // Signal when 10-bit data is received
        .o_data(full_data)        // Output full 10-bit received data
    );

    // Interface UART-ALU instance
    interface_uart_alu #(
        .NB_OP(6),                // Opcode size
        .NB_DATA(8),              // Data size
        .NB_FULL_DATA(10)         // Full data size
    )
    u_interface_uart_alu (
        .i_clk(i_clk),            // Connect to system clock
        .i_reset(i_reset),        // Connect to reset signal
        .i_full_data(full_data),  // Input 10-bit data from UART receiver
        .i_tx_busy(1'b0),         // Assume transmission not busy for now
        .i_full_data_ready(full_data_ready), // Full data ready signal
        .o_operand1(o_operand1),  // Output operand 1
        .o_operand2(o_operand2),  // Output operand 2
        .o_opcode(o_opcode),      // Output opcode
        .o_data_ready(o_data_ready) // Output data ready signal
    );

endmodule
