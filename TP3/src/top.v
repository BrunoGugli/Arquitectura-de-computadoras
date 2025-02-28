module top_pipeline#(
    parameter DATA_BITS = 32,
    parameter STP_BITS_TICKS = 16
)(
    input wire i_clk,
    input wire i_reset,
    input wire i_rx, // Entrada de datos serial desde el testbench
    output wire o_tx // Salida de datos serial hacia el testbench

);

    // Señales del UART
    wire baud_tick;
    wire rx_done;
    wire [DATA_BITS-1:0] rx_data;

    // Señales Debug Unit - Pipeline
    wire write_instruction_flag;
    wire [31:0] instruction_to_write;
    wire [31:0] address_to_write_inst;

    // Instancia del generador de tasa de baudios
    baud_rate_gen #(
        .clk_freq(100000000),  // Reloj de 100 MHz
        .baud_rate(9600)      // Tasa de baudios de 9600 bps
    )
    u_baud_rate_gen (
        .i_clk(i_clk),        // Conectar al reloj del sistema
        .i_reset(i_reset),    // Conectar a la señal de reset
        .i_valid(1'b1),       // Siempre habilitar la generación baud_rate
        .o_baud_tick(baud_tick)  // baud_tick de salida para el receptor
    );

    // Instancia del receptor UART
    uart_receiver #(
        .DATA_BITS(DATA_BITS),       // 32 bits para datos
        .STP_BITS_TICKS(STP_BITS_TICKS)   // 16 ticks para el bit de parada
    )
    u_uart_receiver (
        .i_clk(i_clk),        // Conectar al reloj del sistema
        .i_reset(i_reset),    // Conectar a la señal de reset
        .i_rx(i_rx),          // Conectar a la línea serial de entrada
        .i_bd_tick(baud_tick),// Conectar el baud tick desde baud_rate_gen
        .o_rx_done(rx_done),// Señal de salida cuando la recepción ha terminado
        .o_data(rx_data)      // Datos recibidos 
    );

    // Instancia de la debug unit
    debug_unit u_debug_unit (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_data_ready(rx_done), // Señal que indica que la recepción ha terminado
        .i_data(rx_data), // Datos recibidos
        .o_write_instruction_flag(write_instruction_flag), // Habilitar la escritura de instrucciones
        .o_address_to_write_inst(address_to_write_inst), // Dirección de memoria donde escribir la instrucción
        .o_instruction_to_write(instruction_to_write) // Instrucción a escribir
    );

    // Instancia del pipeline
    pipeline u_pipeline (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_halt(1'b0), // No detener la ejecución
        .i_write_instruction_flag(write_instruction_flag), // Habilitar la escritura de instrucciones
        .i_instruction_to_write(instruction_to_write), // Instrucción a escribir
        .i_address_to_write_inst(address_to_write_inst) // Dirección de memoria donde escribir la instrucción
    );


endmodule