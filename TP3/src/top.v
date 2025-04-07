module top_pipeline#(
    parameter DATA_BITS = 8,
    parameter STP_BITS_TICKS = 16
)(
    input wire i_clk,
    input wire i_reset,
    input wire i_rx, // Entrada de datos serial desde el testbench
    output wire o_tx // Salida de datos serial hacia el testbench

);

    // parametros
    localparam DATA_MEM_DATA_WIDTH = 8; // 1 byte por posicion de memoria
    localparam DATA_MEM_ADDR_WIDTH = 8; // Ancho de la dirección de memoria
    localparam INST_MEM_ADDR_WIDTH = 9; // Ancho de la dirección de memoria de instrucciones
    localparam INST_MEM_DATA_WIDTH = 8; // 1 byte por posicion de memoria

    // Señales del UART
    wire baud_tick;
    wire rx_done;
    wire [DATA_BITS-1:0] rx_data;

    // Señales Debug Unit - Pipeline
    wire write_instruction_flag;
    wire [(INST_MEM_DATA_WIDTH*4)-1:0] instruction_to_write;
    wire [INST_MEM_ADDR_WIDTH-1:0] address_to_write_inst;

    wire [31:0] top_reg_content;
    wire [4:0] top_reg_addr_to_read;

    wire [DATA_MEM_ADDR_WIDTH-1:0] top_addr_to_read_mem_data;

    wire [31:0] top_mem_data_content;

    wire top_program_end;

    wire top_halt;
    wire top_stall;

    wire top_reset_for_pipeline;
    wire top_reset_from_debug;
    wire top_fifo_write_en;

    wire [1:0] top_data_width_to_read_mem_data;

    // Latches pipeline - debug unit
    wire [63:0] top_IF_ID_latch;
    wire [138:0] top_ID_EX_latch;
    wire [75:0] top_EX_MEM_latch;
    wire [70:0] top_MEM_WB_latch;

    // señales UART
    wire [DATA_BITS-1:0] data_to_transmit;
    wire [31:0] data_from_debug;
    wire top_transmit;
    wire top_read_new_data;
    wire top_read_data_from_receiver;
    wire [31:0]data_from_rx_to_debug_unit;

    wire clk_wzrd_locked;
    wire clk_wzrd_out1;
    wire sys_reset;

    clk_wiz_0 clk_wzrd(
    // Clock out ports
    .CLK_50MHz(clk_wzrd_out1),     // output CLK_50MHz
    // Status and control signals
    .locked(clk_wzrd_locked),       // output locked
    .reset(i_reset), // input reset
   // Clock in ports
    .clk_in1(i_clk)      // input clk_in1
    );

    // Instancia del generador de tasa de baudios
    baud_rate_gen #(
        .clk_freq(50000000),  // Reloj de 100 MHz
        .baud_rate(9600)      // Tasa de baudios de 9600 bps
    )
    u_baud_rate_gen (
        .i_clk(clk_wzrd_out1),        // Conectar al reloj del sistema
        .i_reset(sys_reset),    // Conectar a la señal de reset
        .i_valid(1'b1),       // Siempre habilitar la generación baud_rate
        .o_baud_tick(baud_tick)  // baud_tick de salida para el receptor
    );

    // Instancia del receptor UART
    uart_receiver #(
        .DATA_BITS(DATA_BITS),       // 32 bits para datos
        .STP_BITS_TICKS(STP_BITS_TICKS)   // 16 ticks para el bit de parada
    )
    u_uart_receiver (
        .i_clk(clk_wzrd_out1),        // Conectar al reloj del sistema
        .i_reset(sys_reset),    // Conectar a la señal de reset
        .i_rx(i_rx),          // Conectar a la línea serial de entrada
        .i_bd_tick(baud_tick),// Conectar el baud tick desde baud_rate_gen
        .o_rx_done(rx_done),// Señal de salida cuando la recepción ha terminado
        .o_data(rx_data)      // Datos recibidos 
    );

    interface_receive_deb_unit #(
        .SINGLE_DATA_WIDTH(DATA_BITS),     // ancho de datos
        .FULL_DATA_WIDTH(32)     // ancho de datos completo
    ) u_interface_receive_deb_unit (
        .i_clk(clk_wzrd_out1),                           // Reloj del sistema
        .i_reset(sys_reset),                             // Reset del sistema
        .i_data_ready(rx_done),                          // Señal que indica que la recepción ha terminado
        .i_data(rx_data),                           // Datos recibidos
        .o_data_ready(top_read_data_from_receiver),                // Señal de datos listos para el debug unit
        .o_data(data_from_rx_to_debug_unit)                         // Datos completos recibidos
    );

    // Fifo for the transmiter
    fifo_transmitter #(
        .DATA_WIDTH(32), // 32 bits de ancho de datos
        .FIFO_ADDR_WIDTH(8)  // 75 elementos de profundidad
    )
    u_fifo_transmitter (
        .i_clk(clk_wzrd_out1),        // Conectar al reloj del sistema
        .i_reset(sys_reset),    // Conectar a la señal de reset
        .i_wr(top_fifo_write_en),       // No habilitar la escritura
        .i_rd(top_read_new_data),       // Habilitar la lectura
        .i_wr_data(data_from_debug),    // de la debug a la fifo
        .o_rd_data(data_to_transmit), // al transmiter
        .o_empty(top_transmit),           // FIFO vacío
        .o_full()
    );

    // UART transmitter instance
    uart_transmitter #(
        .DATA_BITS(DATA_BITS),          // 8-bit data
        .STP_BITS_TICKS(STP_BITS_TICKS)     // 16 ticks for stop bit
    )
    u_uart_transmitter (
        .i_clk(clk_wzrd_out1),          // Connect to system clock
        .i_reset(sys_reset),      // Connect to reset signal
        .i_tx_start(~top_transmit), 
        .i_bd_tick(baud_tick),  // Connect baud tick from baud_rate_gen
        .i_data(data_to_transmit),
        .o_tx_done(top_read_new_data),        // Output signal to indicate transmission is done
        .o_tx(o_tx)              // Output transmitted data
    );

    // Instancia de la debug unit
    debug_unit #(
        .DATA_MEM_DATA_WIDTH(DATA_MEM_DATA_WIDTH), // 1 byte por posicion de memoria
        .DATA_MEM_ADDR_WIDTH(DATA_MEM_ADDR_WIDTH), // Ancho de la dirección de memoria
        .INST_MEM_ADDR_WIDTH(INST_MEM_ADDR_WIDTH), // Ancho de la dirección de memoria de instrucciones
        .INST_MEM_DATA_WIDTH(INST_MEM_DATA_WIDTH) // 1 byte por posicion de memoria
    ) u_debug_unit (
        .i_clk(clk_wzrd_out1),
        .i_reset(sys_reset),

        // comunicación con el UART
        .i_data_ready(top_read_data_from_receiver), // Señal que indica que la recepción ha terminado
        .i_data(data_from_rx_to_debug_unit), // Datos recibidos

        // comunicación con el pipeline
        .i_program_end(top_program_end), // Señal que indica que el programa ha terminado 
        .i_IF_ID_latch(top_IF_ID_latch),
        .i_ID_EX_latch(top_ID_EX_latch),
        .i_EX_MEM_latch(top_EX_MEM_latch),
        .i_MEM_WB_latch(top_MEM_WB_latch),

        .i_register_content(top_reg_content),
        .i_mem_data_content(top_mem_data_content),

        .o_halt(top_halt),
        .o_reset(top_reset_from_debug),
        .o_stall(top_stall),

        .o_write_instruction_flag(write_instruction_flag), // Habilitar la escritura de instrucciones
        .o_instruction_to_write(instruction_to_write), // Instrucción a escribir
        .o_address_to_write_inst(address_to_write_inst), // Dirección de memoria donde escribir la instrucción
        
        .o_reg_addr_to_read(top_reg_addr_to_read),
        
        .o_addr_to_read_mem_data(top_addr_to_read_mem_data), 
        .o_data_to_fifo(data_from_debug),
        .o_write_en_fifo(top_fifo_write_en)
    );

    // Instancia del pipeline
    pipeline #(
        .DATA_MEM_DATA_WIDTH(DATA_MEM_DATA_WIDTH), // 1 byte por posicion de memoria
        .DATA_MEM_ADDR_WIDTH(DATA_MEM_ADDR_WIDTH), // Ancho de la dirección de memoria  
        .INST_MEM_ADDR_WIDTH(INST_MEM_ADDR_WIDTH), // Ancho de la dirección de memoria de instrucciones
        .INST_MEM_DATA_WIDTH(INST_MEM_DATA_WIDTH) // 1 byte por posicion de memoria 
        )
        u_pipeline (
        
        .i_clk(clk_wzrd_out1),
        .i_reset(top_reset_for_pipeline),
        .i_halt(top_halt), 
        .i_stall(top_stall), 
        .i_write_instruction_flag(write_instruction_flag), // Habilitar la escritura de instrucciones
        .i_instruction_to_write(instruction_to_write), // Instrucción a escribir
        .i_address_to_write_inst(address_to_write_inst), // Dirección de memoria donde escribir la instrucción

        .o_IF_ID_latch(top_IF_ID_latch),
        .o_ID_EX_latch(top_ID_EX_latch),
        .o_EX_MEM_latch(top_EX_MEM_latch),
        .o_MEM_WB_latch(top_MEM_WB_latch),
        
        .i_reg_read(top_reg_addr_to_read), // Dirección de registro a leer
        .o_reg_content(top_reg_content),

        .i_addr_to_read_mem_data_from_debug(top_addr_to_read_mem_data),
        .o_mem_addr_content_to_debug(top_mem_data_content),
       
        .o_program_end(top_program_end)
    );

assign sys_reset = i_reset | !clk_wzrd_locked;
assign top_reset_for_pipeline = top_reset_from_debug | sys_reset;

endmodule