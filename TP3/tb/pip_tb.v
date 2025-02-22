`timescale 1ns / 1ps

module pipeline_tb();

    reg i_clk;
    reg i_reset;
    reg i_halt;
    reg i_write_instruction_flag;
    reg [31:0] i_instruction_to_write;
    reg [31:0] i_address_to_write_inst;

    // Instancia del UUT
    pipeline uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_halt(i_halt),
        .i_write_instruction_flag(i_write_instruction_flag),
        .i_instruction_to_write(i_instruction_to_write),
        .i_address_to_write_inst(i_address_to_write_inst)
    );

    // Generación de reloj
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // Período de 10 unidades de tiempo
    end

    initial begin
        
        // inicialización
        @ (posedge i_clk);
        i_reset = 1;
        i_halt = 1; // Halt activado para evitar la ejecución
        i_write_instruction_flag = 0;
        i_instruction_to_write = 0;
        i_address_to_write_inst = 0;

        #10;
        i_reset = 0;
        i_write_instruction_flag = 1;
        i_address_to_write_inst = 0;
        i_instruction_to_write = 32'b001000_00000_00001_0000000000000010;

        #10;
        i_halt = 0;
        i_write_instruction_flag = 0;



        #1000000000;
        $finish;
    
    end



endmodule

