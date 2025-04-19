`timescale 1ns / 1ns

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
        #1000;

        // Envío de trama UART: "\0lom" en binario es 01101100 01101111 01101101
        
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160); // Esperamos 1 periodo de bit (9600 baudios = ~104160 ns por bit)

        // Enviamos el "m" 01101101 (Reversed: 10110110)
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160); 

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "o" 01101111 (Reversed: 11110110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "l" 01101100 (Reversed: 00110110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "\0" 00000000 (Reversed: 00000000)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160); 

        // 01000000 00000000 10000000 00000100; instrucción ADDI $1, $0, 2

        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);
        
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        

        // 00010000 00000000 01000000 00000100 instrucción ADDI $2, $0, 8 
        
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);


        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        
        // Bit de parada (1)
        tb_rx = 1; #(104160);

        
        // 00000100 00011000 01000100 00000000 instrucción ADD $3, $1, $2 
        
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        // 10101100 00000011 00000000 00000100 instrucción SW $3, $0, 4

        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);


        // 10101100 00000011 00000000 00001000 instrucción SW $3, $0, 8
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        // 10100100 00000011 00000000 00001000  SH $3, $0, 8
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);



        // 10100100 00000011 00000000 00001010  SH $3, $0, 10
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);



        // 11111111 11111111 11111111 11111111 instrucción END

        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        

        //Envío de trama UART: "\0com" en binario es 01100011 01101111 01101101
        
        //Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "m" 01101101 (Reversed: 10110110)
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "o" 01101111 (Reversed: 11110110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "c" 01100011 (Reversed: 11000110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "\0" 00000000 (Reversed: 00000000)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);


        // Esperamos algunos ciclos antes de enviar datos
        //#(230000000);


        // Envío de trama UART: "\0com" en binario es 01100011 01101111 01101101
        
        // Bit de inicio (0)
        // @(posedge tb_clk);
        // tb_rx = 0; #(104160);

        // // Enviamos el "m" 01101101 (Reversed: 10110110)
        // tb_rx = 1; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 0; #(104160);

        // tb_rx = 1; #(104160);

        // @(posedge tb_clk);
        // tb_rx = 0; #(104160);

        // // Enviamos el "o" 01101111 (Reversed: 11110110)
        // tb_rx = 1; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 0; #(104160);

        // tb_rx = 1; #(104160);

        // @(posedge tb_clk);
        // tb_rx = 0; #(104160);

        // // Enviamos el "c" 01100011 (Reversed: 11000110)
        // tb_rx = 1; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 1; #(104160);
        // tb_rx = 0; #(104160);

        // tb_rx = 1; #(104160);

        // @(posedge tb_clk);
        // tb_rx = 0; #(104160);

        // // Enviamos el "\0" 00000000 (Reversed: 00000000)
        // tb_rx = 0; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 0; #(104160);
        // tb_rx = 0; #(104160);

        // // Bit de parada (1)
        // tb_rx = 1; #(104160);

        







/*
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "m" 01101101 (Reversed: 10110110)
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "t" 01110100 (Reversed: 00101110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "s" 01110011 (Reversed: 11001110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "\0" 00000000 (Reversed: 00000000)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        // Esperamos algunos ciclos antes de enviar datos
        #150;

        // Envio del "nxst"
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "t" 01110100 (Reversed: 00101110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "s" 01110011 (Reversed: 11001110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "x" 01111000 (Reversed: 00011110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "n" 01101110 (Reversed: 01110110)
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        // Esperamos algunos ciclos antes de enviar datos
        #150;

        // Envio del "nxst"
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "t" 01110100 (Reversed: 00101110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "s" 01110011 (Reversed: 11001110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "x" 01111000 (Reversed: 00011110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "n" 01101110 (Reversed: 01110110)
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        // Esperamos algunos ciclos antes de enviar datos
        #150;

        // Envio del "nxst"
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "t" 01110100 (Reversed: 00101110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "s" 01110011 (Reversed: 11001110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "x" 01111000 (Reversed: 00011110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "n" 01101110 (Reversed: 01110110)
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        // Esperamos algunos ciclos antes de enviar datos
        #150;

        // Envio del "nxst"
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "t" 01110100 (Reversed: 00101110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "s" 01110011 (Reversed: 11001110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "x" 01111000 (Reversed: 00011110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "n" 01101110 (Reversed: 01110110)
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);
        

        // Esperamos algunos ciclos antes de enviar datos
        #150;

        // Envio del "nxst"
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "t" 01110100 (Reversed: 00101110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "s" 01110011 (Reversed: 11001110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "x" 01111000 (Reversed: 00011110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "n" 01101110 (Reversed: 01110110)
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        // Esperamos algunos ciclos antes de enviar datos
        #150;

        // Envio del "nxst"
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "t" 01110100 (Reversed: 00101110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "s" 01110011 (Reversed: 11001110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "x" 01111000 (Reversed: 00011110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "n" 01101110 (Reversed: 01110110)
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        // Esperamos algunos ciclos antes de enviar datos
        #150;

        // Envio del "nxst"
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "t" 01110100 (Reversed: 00101110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "s" 01110011 (Reversed: 11001110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "x" 01111000 (Reversed: 00011110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "n" 01101110 (Reversed: 01110110)
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

        // Envio del "clst"
        // Bit de inicio (0)
        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "t" 01110100 (Reversed: 00101110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "s" 01110011 (Reversed: 11001110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "l" 01101100 (Reversed: 00110110)
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        tb_rx = 1; #(104160);

        @(posedge tb_clk);
        tb_rx = 0; #(104160);

        // Enviamos el "c" 01100011 (Reversed: 11000110)
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 0; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 1; #(104160);
        tb_rx = 0; #(104160);

        // Bit de parada (1)
        tb_rx = 1; #(104160);

*/

        
        // Esperar la recepción del dato
        #2000000;

        // Finalizamos la simulación
        $finish;
    end


endmodule
