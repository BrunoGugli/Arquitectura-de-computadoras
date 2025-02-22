module tb_fill_and_read_memory();

    // Señales para el UUT
    reg i_clk;
    reg i_reset;
    reg i_stall;
    reg i_halt;
    reg i_write_instruction;
    reg [31:0] i_instruction;
    reg [31:0] i_address;
    wire [31:0] o_instruction;
    wire [31:0] o_pc;

    // Instancia del UUT
    instruction_fetch uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_stall(i_stall),
        .i_halt(i_halt),
        .i_write_instruction(i_write_instruction),
        .i_instruction(i_instruction),
        .i_address(i_address),
        .o_instruction(o_instruction),
        .o_pc(o_pc)
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
        i_write_instruction = 0;
        i_instruction = 0;
        i_address = 0;

        // Ciclo de reset
        @ (posedge i_clk);
        i_reset = 0;
        i_write_instruction = 1;
        for (integer i = 0 ; i < 256 ; i = i + 4 ) begin            

            i_address = i;
            @ (posedge i_clk);
            i_instruction = i+1;
            @ (posedge i_clk);
            $display("Escribiendo instrucción %d en la dirección %d", i_instruction, i_address);
        end


        i_write_instruction = 0;
        i_address = 0;
        @ (posedge i_clk);
        i_halt = 0;

    end
    

endmodule
