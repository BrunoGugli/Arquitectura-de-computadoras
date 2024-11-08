`timescale 1ns/1ps

module tb_top_uart_rx();

    // Señales del testbench
    reg tb_clk;               // Reloj del sistema
    reg tb_reset;             // Señal de reset
    reg tb_rx;                // Señal de datos RX
    wire tb_rx_done;          // Indica cuando se completó la recepción
    wire tb_data_valid;       // Señal de datos válidos
    wire tb_is_on;            // Señal de encendido del sistema
    wire tb_operand1_ready;   // Señal de operand1 listo
    wire tb_operand2_ready;   // Señal de operand2 listo
    wire tb_opcode_ready;     // Señal de opcode listo
    wire tb_tx;               // Señal de transmisión TX
    
    // Instancia del módulo top que conecta baud rate gen y UART receiver
    top_uart u_top_uart (
        .i_clk(tb_clk),
        .i_reset(tb_reset),
        .i_rx(tb_rx),
        .o_rx_done(tb_rx_done),
        .o_tx(tb_tx),
        .o_data_valid(tb_data_valid),
        .o_is_on(tb_is_on),
        .operand1_ready(tb_operand1_ready),
        .operand2_ready(tb_operand2_ready),
        .opcode_ready(tb_opcode_ready)
    );

    // Generación del reloj de 50 MHz (periodo 20 ns)
    initial begin
        tb_clk = 0;
        forever #10 tb_clk = ~tb_clk;
    end

    // Simulación de una trama UART: bit de inicio (0), 10 bits de datos, bit de parada (1)
    initial begin

        // Llevamos el sistema a un estado conocido
        @(posedge tb_clk); 
        tb_reset = 1;
        tb_rx = 1; // Inactivo (idle) en el bus UART es 1
        @(posedge tb_clk);
        tb_reset = 0;
        
        // Esperamos algunos ciclos antes de enviar datos
        #20

        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0;
        #(104160); // Esperamos 1 periodo de bit (9600 baudios = ~104160 ns por bit)

        // Enviamos los 8 bits de datos (85 -> 01010101)
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Enviamos el opcode de operando 00 -> operando 1
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1;
        #(104160); 

        // Esperar la recepción del dato
        #200000;

        // mandamos otro dato
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0;
        #(104160); // Esperamos 1 periodo de bit (9600 baudios = ~104160 ns por bit)

        // Enviamos los 8 bits de datos (245 -> 11110101)
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);

        // Enviamos el opcode de operando 01 -> operando 2
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1;
        #(104160);

        // Esperar la recepción del dato
        #200000; 

        // mandamos el opcode suma
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0;
        #(104160); // Esperamos 1 periodo de bit (9600 baudios = ~104160 ns por bit)

        // Enviamos los 6 bits de datos (suma -> 6'b100000)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160); //idle
        tb_rx = 0; #(104160); //idle

        // Enviamos el opcode de operador 10 -> opcode 
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);

        // Bit de parada (1)
        tb_rx = 1;
        #(104160); 

        // Esperar la recepción del dato
        #240000;

        // Finalizamos la simulación
        $finish;
    end


endmodule
