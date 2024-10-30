module top_uart
(
    input wire i_clk,       // System clock from testbench
    input wire i_reset,     // Reset signal from testbench
    input wire i_rx,        // Serial data input from testbench
    output wire o_rx_done,  // Output flag when reception is done
    output wire [9:0] o_data, // Output received data (now 10 bits)
    output wire [7:0] o_operand1, // Output operand 1
    output wire [7:0] o_operand2, // Output operand 2
    output wire [1:0] o_opcode, // Output opcode
    output wire o_data_valid // Output data valid
);

    // Signals to connect baud_rate_gen and uart_receiver
    wire baud_tick;

    // Signals to connect uart_receiver and interface ALU-UART
    wire data_ready; // wire to connect 

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

    // UART receiver instance (now 10 bits)
    uart_receiver #(
        .DATA_BITS(10),       // 10-bit data (modified)
        .STP_BITS_TICKS(16)   // 16 ticks for stop bit
    )
    u_uart_receiver (
        .i_clk(i_clk),        // Connect to system clock
        .i_reset(i_reset),    // Connect to reset signal
        .i_rx(i_rx),          // Connect to received data
        .i_bd_tick(baud_tick),// Connect baud tick from baud_rate_gen
        .o_rx_done(o_rx_done),// Output signal when reception is done
        .o_data(o_data)       // Output received data (now 10 bits)
    );

    // Interface ALU-UART instance
    interface_uart_alu #(
        .NB_OP(6),            // 2-bit opcode
        .NB_DATA(8),          // 8-bit data
        .NB_FULL_DATA(10)     // 10-bit full data
    )
    u_interface_alu_uart (
        .i_clk(i_clk),        // Connect to system clock
        .i_reset(i_reset),    // Connect to reset signal
        .i_full_data(o_data), // Connect the full data from uart_receiver to interface ALU-UART
        .i_tx_busy(1'b0),     // Always enable the transmission
        .i_full_data_ready(o_rx_done) // Connect the reception done signal to indicate full data ready
    );

endmodule
