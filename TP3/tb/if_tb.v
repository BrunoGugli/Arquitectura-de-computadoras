module tb_instruction_fetch();

    // Señales para el DUT
    reg i_clk;
    reg i_reset;
    reg i_stall;
    reg i_halt;
    reg i_write_instruction;
    reg [31:0] i_instruction;
    reg [31:0] i_address;
    wire [31:0] o_instruction;
    wire [31:0] o_pc;

    // Instancia del DUT
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

    // Prueba
    initial begin

        // Llevamos el sistema a un estado conocido
        @ (posedge i_clk); // Esperar un ciclo de reloj
        i_reset = 1;
        i_stall = 0;
        i_halt = 0;
        i_write_instruction = 0;
        i_instruction = 32'h0;
        i_address = 32'h0;

        // Escribimos un par de datos en la memoria de instrucciones
        @ (posedge i_clk); // 
        i_reset = 0;
        i_halt = 1;
        i_write_instruction = 1;

        // una instrucción por ciclo en direcciones consecutivas
        @ (posedge i_clk);
        i_instruction = 32'h10101010;
        i_address = 32'h0;
        @ (posedge i_clk);
        i_instruction = 32'h12345678;
        i_address = 32'h4;
        @ (posedge i_clk);
        i_instruction = 32'habcdef01;
        i_address = 32'h8;
        @ (posedge i_clk);
        i_instruction = 32'hfedcba98;
        i_address = 32'hc;
        @ (posedge i_clk);
        i_instruction = 32'h0;
        i_address = 32'h0;

        @ (posedge i_clk);
        i_write_instruction = 0;
        @ (posedge i_clk);
        i_halt = 0;

        // Finalizar prueba
        #200000; 
        $stop;
    end

    always @ (posedge i_clk) begin
        $display("PC: %h, Instruction: %h", o_pc, o_instruction);
    end



endmodule
