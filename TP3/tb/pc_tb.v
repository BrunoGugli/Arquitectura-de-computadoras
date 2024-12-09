module tb_program_counter();

    // Señales para el DUT
    reg i_clk;
    reg i_reset;
    reg [31:0] i_jump_address;
    reg i_jump;
    reg i_stall;
    reg i_halt;
    wire [31:0] o_pc;

    // Instancia del DUT
    program_counter ut_program_counter (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_stall(i_stall),
        .i_halt(i_halt),
        .o_pc(o_pc),
        .i_jump_address(i_jump_address),
        .i_jump(i_jump)
    );

    // Generación de reloj
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // Período de 10 unidades de tiempo
    end

    // Prueba para llenar y leer la memoria
    initial begin
        // Inicialización
        @ (posedge i_clk);
        i_reset = 1;
        i_stall = 0;
        i_halt = 1; // Halt activado para evitar la ejecución
        i_jump = 0;
        
        @ (posedge i_clk);
        i_reset = 0;
        i_halt = 0;
    end
    

endmodule
