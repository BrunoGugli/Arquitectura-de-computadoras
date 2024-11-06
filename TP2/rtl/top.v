module top_uart #(
    parameter NB_OUT = 16
)
(
    input wire i_clk,           // System clock from testbench
    input wire i_reset,         // Reset signal from testbench
    input wire i_rx,            // Serial data input from testbench
    output wire o_rx_done,      // Output flag when reception is done
    output wire o_tx,           // Serial data output to testbench
    output wire o_data_valid,    // Output data valid
    output wire o_is_on // Output flag to indicate if the system is on
);

    // Set o_is_on to 1
    assign o_is_on = 1;

    // Signals to connect baud_rate_gen and uart_receiver
    wire baud_tick;

    // Signals to connect uart_receiver and interface ALU-UART
    wire data_ready; // Wire to indicate when data is ready in the UART receiver

    wire busy; // Wire to indicate when the UART transmitter is busy

    // Signals to connect interface_uart_alu and ALU
    wire [7:0] operand1;
    wire [7:0] operand2;
    wire [5:0] opcode;

    // Signal to connect rx and interface
    wire [9:0] rx_data;

    // Signal to connect ALU and tx
    wire [NB_OUT-1:0] result;

    // Señal para capturar o_tx_done
    wire tx_done; // Señal intermedia para conectar o_tx_done

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
        .o_data(rx_data)      // Output received data (now 10 bits)
    );

    // Interface ALU-UART instance
    interface_uart_alu #(
        .NB_OP(6),            // 6-bit opcode
        .NB_DATA(8),          // 8-bit data
        .NB_FULL_DATA(10)     // 10-bit full data
    )
    u_interface_alu_uart (
        .i_clk(i_clk),             // Connect to system clock
        .i_reset(i_reset),         // Connect to reset signal
        .i_full_data(rx_data),     // Connect the full data from uart_receiver to interface ALU-UART
        .i_tx_busy(busy),          // Set TX busy to 0 (not using transmission in this example)
        .i_full_data_ready(o_rx_done), // Connect the reception done signal to indicate full data ready
        .o_operand1(operand1),     // Operand 1 from UART interface
        .o_operand2(operand2),     // Operand 2 from UART interface
        .o_opcode(opcode),         // Opcode from UART interface
        .o_data_ready(o_data_valid) // Output data ready for ALU processing
    );

    // ALU instance
    ALU #(
        .NB_OP(6),
        .NB_DATA(8),
        .NB_OUT(NB_OUT)
    )
    u_alu (
        .i_operand1(operand1),    // Connect to operand1 output from interface
        .i_operand2(operand2),    // Connect to operand2 output from interface
        .i_opcode(opcode),        // Connect to opcode output from interface
        .o_result(result)         // ALU output result
    );

    // UART transmitter instance
    uart_transmitter #(
        .DATA_BITS(8),          // 8-bit data
        .STP_BITS_TICKS(16)     // 16 ticks for stop bit
    )
    u_uart_transmitter (
        .i_clk(i_clk),          // Connect to system clock
        .i_reset(i_reset),      // Connect to reset signal
        .i_tx_start(o_data_valid), // Connect to data valid signal from ALU
        .i_bd_tick(baud_tick),  // Connect baud tick from baud_rate_gen
        .i_data(result[7:0]),   // Line to transmit 8 LSBs of data from ALU
        .o_tx_transmiting(busy), // Output signal to indicate transmission is in progress
        .o_tx_done(tx_done),     // Connect o_tx_done to tx_done (not used here)
        .o_tx(o_tx)              // Output transmitted data
    );

endmodule
