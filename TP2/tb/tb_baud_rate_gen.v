`timescale 1ns/1ps

module tb_top_uart_rx();

    // Señales del testbench
    reg tb_clk;               // Reloj del sistema
    reg tb_reset;             // Señal de reset
    reg tb_rx;                // Señal de datos RX
    wire tb_rx_done;          // Indica cuando se completó la recepción
    wire [9:0] tb_data;       // Dato recibido por el UART (10 bits)

    // Instancia del módulo top que conecta baud rate gen y UART receiver
    top_uart u_top_uart (
        .i_clk(tb_clk),
        .i_reset(tb_reset),
        .i_rx(tb_rx),
        .o_rx_done(tb_rx_done),
        .o_data(tb_data)
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

        // Envío de trama UART: 10'b1101010101 (opcode 11, datos 85 en decimal)
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0;
        #(104160); // Esperamos 1 periodo de bit (9600 baudios = ~104160 ns por bit)

        // Enviamos el opcode de operando 01 -> operando 1
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);

        // Enviamos los 8 bits de datos (0x55 = 8'b01010101)
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1;
        #(104160); 

        // Esperar la recepción del dato
        #200000;

        // mandamos otro dato
        tb_rx = 0;
        #(104160); // Esperamos 1 periodo de bit (9600 baudios = ~104160 ns por bit)

        // Enviamos los 2 bits de opcode 10 -> operando 2

        // Enviamos los 8 bits de datos (0x55 = 8'b01010101)
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        
        // Bit de parada (1)
        tb_rx = 1;
        #(104160);

        // Esperar la recepción del dato
        #200000;

        // mandamos otro dato

        tb_rx = 0;
        #(104160); // Esperamos 1 periodo de bit (9600 baudios = ~104160 ns por bit)

        // Enviamos los 2 bits de opcode 11 -> operador
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);

        // Enviamos los 8 bits de datos (0x55 = 8'b01010101)
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1;
        #(104160);

        // Esperar la recepción del dato
        #200000;


        // Finalizamos la simulación
        $finish;
    end

    // Monitor de las señales de salida
    always @(posedge tb_clk) begin
        if (tb_rx_done) begin
            $display("Dato recibido: %b, Tiempo: %0t", tb_data, $time);
        end
    end

endmodule
