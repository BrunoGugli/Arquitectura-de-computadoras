`timescale 1ns / 1ps

module instruction_decode_tb;

    reg i_clk;
    reg i_reset;
    reg [31:0] i_instruction;
    reg [31:0] i_pc;

    // cosas hacia el register bank
    reg i_ctl_wb_reg_write_wb;
    reg [4:0] i_write_addr_wb;
    reg [31:0] i_write_data_wb;

    // cosas del detect hazard
    reg i_stall;
    reg i_halt;

    // cosas que van hacia la etapa de EX
    wire [31:0] o_RA; // dato de rs
    wire [31:0] o_RB; // dato de rt
    wire [ 4:0] o_rs; // direccion de rs
    wire [ 4:0] o_rt; // direccion de rt
    wire [ 4:0] o_rd; // direccion de rd
    wire [ 5:0] o_funct; // codigo de operacion especifico para sumas; restas; etc
    wire [31:0] o_inmediato; // inmediato
    wire [ 5:0] o_opcode; // codigo de operacion para el tipo de instruccion
    wire [ 4:0] o_shamt; // indica el desplazamiento de bitswire
    
    // WB control signals
    wire o_ctl_WB_mem_to_reg_ID; // 0 -> MEM to reg; 1 -> ALU to reg
    wire o_ctl_WB_reg_write_ID;

    // MEM control signals
    wire o_ctl_MEM_mem_read_ID;
    wire o_ctl_MEM_mem_write_ID;
    wire o_ctl_MEM_unsigned_ID;
    wire [1:0] o_ctl_MEM_data_width_ID; // 00 -> byte; 01 -> halfword; 11 -> word

    // EX control signals
    wire o_ctl_EX_reg_dest_ID;
    wire [1:0] o_ctl_EX_ALU_op_ID;
    wire o_ctl_EX_ALU_src_ID;

    // jumps
    wire o_jump;
    wire [31:0] o_jump_address;
    wire [1:0] o_reg_in_jump; // 00 -> not jump; 01 -> jump with rs and rt; 10 -> jump with rs only

    wire o_halt;

    instruction_decode uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_instruction(i_instruction),
        .i_pc(i_pc),
        .i_ctl_wb_reg_write_wb(i_ctl_wb_reg_write_wb),
        .i_write_addr_wb(i_write_addr_wb),
        .i_write_data_wb(i_write_data_wb),
        .i_stall(i_stall),
        .i_halt(i_halt),
        .o_RA(o_RA),
        .o_RB(o_RB),
        .o_rs(o_rs),
        .o_rt(o_rt),
        .o_rd(o_rd),
        .o_funct(o_funct),
        .o_inmediato(o_inmediato),
        .o_opcode(o_opcode),
        .o_shamt(o_shamt),
        .o_ctl_WB_mem_to_reg_ID(o_ctl_WB_mem_to_reg_ID),
        .o_ctl_WB_reg_write_ID(o_ctl_WB_reg_write_ID),
        .o_ctl_MEM_mem_read_ID(o_ctl_MEM_mem_read_ID),
        .o_ctl_MEM_mem_write_ID(o_ctl_MEM_mem_write_ID),
        .o_ctl_MEM_unsigned_ID(o_ctl_MEM_unsigned_ID),
        .o_ctl_MEM_data_width_ID(o_ctl_MEM_data_width_ID),
        .o_ctl_EX_reg_dest_ID(o_ctl_EX_reg_dest_ID),
        .o_ctl_EX_ALU_op_ID(o_ctl_EX_ALU_op_ID),
        .o_ctl_EX_ALU_src_ID(o_ctl_EX_ALU_src_ID),
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
        
        // Incialización de señales
        @ (posedge i_clk);
        i_reset = 1;
        i_instruction = 0;
        i_pc = 0;
        i_ctl_wb_reg_write_wb = 0;
        i_write_addr_wb = 0;
        i_write_data_wb = 0;
        i_stall = 0;
        i_halt = 0;

        // Salgo del reset
        #10;
        i_reset = 0;

        //--Incialización de registros--
        #10;
        i_ctl_wb_reg_write_wb = 1;
        i_write_addr_wb = 5'd1;
        i_write_data_wb = 32'h00000010; // $1 = 0x10 -> 16
        
        #10;
        i_ctl_wb_reg_write_wb = 0;
        
        // Test 1: Load word ( LW $2, 4($1) ) 
        i_instruction = 32'b10001100001000100000000000000100;
        i_pc = 32'h00000004;

        #1000;
    end



endmodule


