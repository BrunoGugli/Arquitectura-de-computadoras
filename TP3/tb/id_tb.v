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
    wire o_ctl_EX_reg_dest_ID; // 0 -> rt; 1 -> rd
    wire [1:0] o_ctl_EX_ALU_op_ID;
    wire o_ctl_EX_ALU_src_ID; // 0 -> Mux forwarding; 1 -> Inmediato

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
        @ (posedge i_clk);
        i_ctl_wb_reg_write_wb = 1;
        i_write_addr_wb = 5'd1;
        i_write_data_wb = 32'h00000010; // $1 = 0x10 -> 16
        
        @ (posedge i_clk);
        i_write_addr_wb = 5'd3;
        i_write_data_wb = 32'h00000030; // $3 = 0x30 -> 48
        
        #10;
        i_ctl_wb_reg_write_wb = 0;
        
        // Test 1: Load word ( LW $2, 4($1) ) 
        i_instruction = 32'b100011_00001_00010_0000000000000100;
        i_pc = 32'h00000004;

        #10;
        // Test 2: Shift left logical ( SLL $2, $3, 4)
        i_instruction = 32'b00000000000000110001000100000000;
        i_pc = 32'h00000008;

        #10;
        // Test 3: Shift right logical ( SRL $2, $3, 4)
        i_instruction = 32'b00000000000000110001000100000010;
        i_pc = 32'h0000000C;

        #10;
        // Test 4: Shift right arithmetic ( SRA $2, $3, 10)
        i_instruction = 32'b000000_00000_00011_00010_00100_000011;
        i_pc = 32'h00000010;

        #10;
        // Test 5: Add ( ADD $2, $3, $1)
        i_instruction = 32'b000000_00011_00001_00010_00000_100000;
        i_pc = 32'h00000014;

        #10;
        // Test 6: JAL 5 -> 54 = 20
        i_instruction = 32'b000011_00000_00000_00000_00000_000101;
        i_pc = 32'h00000018;

        #10;
        // Test 7: BEQ r0,r0,5 -> 54 = 20
        i_instruction = 32'b000100_00000_00000_00000_00000_000101;
        i_pc = 32'h0000001C;

        #10;
        // Test 8: JALR $2, $4, 0
        i_instruction = 32'b000000_00100_00000_00010_00000_001001;
        i_pc = 32'h00000020;


        #1000;
    end



endmodule


