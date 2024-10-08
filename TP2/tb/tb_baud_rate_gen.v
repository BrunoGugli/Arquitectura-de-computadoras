`timescale 1ns / 1ps

module tb_baud_rate_gen();

    // signals
    reg tb_clk;
    reg tb_reset;
    reg tb_valid;
    wire tb_baud_tick;

    // Instanciación del DUT (Device Under Test)
    // No sobrescribimos los parámetros, se usarán los valores por defecto
    baud_rate_gen dut (
        .i_clk(tb_clk),
        .i_reset(tb_reset),
        .i_valid(tb_valid),
        .o_baud_tick(tb_baud_tick)
    );

    // Generación del reloj de 100 MHz (periodo = 10 ns)
    initial begin
        tb_clk = 0;
        forever #5 tb_clk = ~tb_clk; // 100 MHz clock (10 ns de periodo)
    end

    // Testbench principal
    initial begin
        // Llevar el sistema a un estado conocido
        @(posedge tb_clk); // Esperar un ciclo de reloj
        tb_reset = 1;   // Reset activo
        tb_valid = 0;   // Desactivar la generación del baud rate
        @(posedge tb_clk); // Esperar un ciclo de reloj
        tb_reset = 0;   // Desactivar reset

        // Activar la generación del baud rate
        @(posedge tb_clk);
        tb_valid = 1;

        // Esperar a que se genere un tick
        wait(tb_baud_tick == 1);

        // Mostrar mensaje cuando se detecte el primer tick
        $display("Tick at %t, counter = %d", $time, dut.counter);

        // Finalizar la simulación después de detectar el tick
        $finish;
    end

endmodule
