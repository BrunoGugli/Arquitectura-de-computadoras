`timescale 1ps/1ps

module tb_instruction_decode();

    reg i_clk;
    reg i_reset;
    reg [31:0] i_instruction;
    reg [31:0] i_pc;

    // inputs del register bank 
    reg i_id_write_enable_wb;
    reg [4:0] i_id_write_addr;
    reg [31:0] i_id_write_data;

    // hazard detection unit
    reg i_stall;
    reg i_halt;

    // outputs del instruction decode
    wire [31:0] o_RA;
    wire [31:0] o_RB;
    wire [31:0] o_rs;    
    wire [31:0] o_rt;
    wire [31:0] o_rd;
    wire [5:0] o_funct;
    wire [5:0] o_opcode;
    wire [5:0] o_shamt;
    wire [31:0] o_immediate;

    // WB control signals
    wire o_WB_mem_to_reg_ID;
    wire o_WB_write_reg_ID;
    
    // MEM control signals
    wire o_MEM_mem_read_ID;
    wire o_MEM_mem_write_ID;
    wire o_MEM_signed_ID;
    wire [1:0] o_MEM_data_width_ID;

    // EX control signals
    wire o_EX_reg_dest_ID;
    wire [1:0] o_EX_alu_op_ID;
    wire o_EX_alu_src_ID;

    // Jump control signals
    wire o_jump;
    wire [31:0] o_jump_address; //porque se calcula en  ID
    wire [1:0] o_reg_in_jump;
    
    wire o_halt;

    // instanciacion del modulo
    tb_instruction_decode uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_instruction(i_instruction),
        .i_pc(i_pc),
        .i_id_write_enable_wb(i_id_write_enable_wb),
        .i_id_write_addr(i_id_write_addr),
        .i_id_write_data(i_id_write_data),
        .i_stall(i_stall),
        .i_halt(i_halt),
        .o_RA(o_RA),
        .o_RB(o_RB),
        .o_rs(o_rs),
        .o_rt(o_rt),
        .o_rd(o_rd),
        .o_funct(o_funct),
        .o_inmediato(o_immediate),
        .o_opcode(o_opcode),
        .o_shamt(o_shamt),
        .o_WB_mem_to_reg_ID(o_WB_mem_to_reg_ID),
        .o_WB_write_reg_ID(o_WB_write_reg_ID),
        .o_MEM_mem_read_ID(o_MEM_mem_read_ID),
        .o_MEM_mem_write_ID(o_MEM_mem_write_ID),
        .o_MEM_signed_ID(o_MEM_signed_ID),
        .o_MEM_data_width_ID(o_MEM_data_width_ID),
        .o_EX_reg_dest_ID(o_EX_reg_dest_ID),
        .o_EX_alu_op_ID(o_EX_alu_op_ID),
        .o_EX_alu_src_ID(o_EX_alu_src_ID),
        .o_jump(o_jump),
        .o_jump_address(o_jump_address),
        .o_reg_in_jump(o_reg_in_jump),
        .o_halt(o_halt)
    );

    // Generación de reloj
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // Período de 10 unidades de tiempo
    end

    initial begin

        // Inicializar señales
        @ (posedge i_clk);
        i_reset = 1;
        i_instruction = 0;
        i_pc = 0;
        i_id_write_enable_wb = 0;
        i_id_write_addr = 0;
        i_id_write_data = 0;
        i_stall = 0;
        i_halt = 0;

        // Salgo del reset
        @ (posedge i_clk);
        i_reset = 0;

        // Prueba de instrucciones

        // Test 1: Instrucción tipo R ( add $t0, $t1, $t2 )
        i_instruction = 0'b00000001001010100100000000100000;

    end





    





endmodule