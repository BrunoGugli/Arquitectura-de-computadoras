`timescale 1ns/1ps

module tb_top_pipeline();

    // Señales del testbench
    reg tb_clk;               // Reloj del sistema
    reg tb_reset;             // Señal de reset
    reg tb_rx;                // Señal de datos RX
    wire [31:0] tb_data;       // Dato recibido por el UART (32 bits)
    wire tb_tx;               // Señal de datos TX

    // Instancia del módulo top que conecta el pipeline con el UART y la debug unit
    top_pipeline u_top_pipeline (
        .i_clk(tb_clk),        // Conectar al reloj del sistema
        .i_reset(tb_reset),    // Conectar a la señal de reset
        .i_rx(tb_rx),          // Conectar a la línea serial de entrada
        .o_tx(tb_tx)           // Conectar a la línea serial de salida
    );

    // Generación del reloj de 50 MHz (periodo 20 ns)
    initial begin
        tb_clk = 0;
        forever #5 tb_clk = ~tb_clk;
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

        // Envío de trama UART: "\0lom" en binario es 01101100 01101111 01101101
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0;
        #(104160); // Esperamos 1 periodo de bit (9600 baudios = ~104160 ns por bit)

        // Enviamos el "\0" 00000000
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        
        // Enviamos el "l" 01101100
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        // Enviamos el "o" 01101111
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);

        // Enviamos el "m" 01101101
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);

        // Bit de parada (1)
        tb_rx = 1;
        #(104160); 

        // Esperar la recepción del dato
        #2000000;

        // Finalizamos la simulación
        $finish;
    end


endmodule
