module pipeline (

    input wire i_clk,
    input wire i_reset,
    input wire i_halt,
    input wire i_write_instruction_flag,
    input wire [31:0] i_instruction_to_write,
    input wire [31:0] i_address_to_write_inst
);


//------------------------------------------------- CABLES --------------------------------------------------------------
  
    // IF/ID
    wire [31:0] IF_ID_instruction;
    wire [31:0] IF_ID_pc;

    // ID/EX
    wire [31:0] ID_EX_RA;
    wire [31:0] ID_EX_RB;
    wire [4:0] ID_EX_rs;
    wire [4:0] ID_EX_rt;
    wire [4:0] ID_EX_rd;
    wire [5:0] ID_EX_funct;
    wire [31:0] ID_EX_inmediato;
    wire [5:0] ID_EX_opcode;
    wire [4:0] ID_EX_shamt;

    wire ID_EX_ctl_WB_mem_to_reg;
    wire ID_EX_ctl_WB_reg_write;

    wire ID_EX_ctl_MEM_mem_read;
    wire ID_EX_ctl_MEM_mem_write;
    wire ID_EX_ctl_MEM_unsigned;

    wire [1:0] ID_EX_ctl_MEM_data_width;
    wire ID_EX_ctl_EX_reg_dest;
    wire ID_EX_ctl_EX_ALU_op;
    wire ID_EX_ctl_EX_alu_src;

    // EX/MEM
    wire [31:0] EX_MEM_ALU_result;
    wire [31:0] EX_MEM_data_to_write;
    wire [4:0] EX_MEM_reg_dest;






    instruction_fetch u_instruction_fetch (

        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_stall(1'b0), //viene de la hazard unit
        .i_halt(i_halt),
        .i_write_instruction_flag(i_write_instruction_flag),
        .i_instruction_to_write(i_instruction_to_write),
        .i_address_to_write_inst(i_address_to_write_inst),
        .o_instruction(IF_ID_instruction),
        .o_pc(IF_ID_pc)
    );

    instruccion_decode u_instruccion_decode (

        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_instruction(IF_ID_instruction),
        .i_pc(IF_ID_pc),

        .i_ctl_wb_reg_write_wb(1'b0), //viene de write back
        .i_write_addr_wb(5'b0), //viene de write back
        .i_write_data_wb(32'b0), //viene de write back
        .i_stall(1'b0), //viene de la hazard unit
        .i_halt(i_halt),

        .o_RA(ID_EX_RA),
        .o_RB(ID_EX_RB),
        .o_rs(ID_EX_rs),
        .o_rt(ID_EX_rt),
        .o_rd(ID_EX_rd),
        .o_funct(ID_EX_funct),
        .o_inmediato(ID_EX_inmediato),
        .o_opcode(ID_EX_opcode),
        .o_shamt(ID_EX_shamt),

        .o_ctl_WB_mem_to_reg_ID(ID_EX_ctl_WB_mem_to_reg),
        .o_ctl_WB_reg_write_ID(ID_EX_ctl_WB_reg_write),

        .o_ctl_MEM_mem_read_ID(ID_EX_ctl_MEM_mem_read),
        .o_ctl_MEM_mem_write_ID(ID_EX_ctl_MEM_mem_write),
        .o_ctl_MEM_unsigned_ID(ID_EX_ctl_MEM_unsigned),
        .o_ctl_MEM_data_width_ID(ID_EX_ctl_MEM_data_width),
        
        .o_ctl_EX_reg_dest_ID(ID_EX_ctl_EX_reg_dest),
        .o_ctl_EX_ALU_op_ID(ID_EX_ctl_EX_ALU_op),
        .o_ctl_EX_alu_src_ID(ID_EX_ctl_EX_alu_src),

        .o_jump(),
        .o_jump_address(),
        .o_reg_in_jump()
    );

    instruccion_execute u_instruccion_execute (

        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_halt(i_halt),

        .i_ctl_EX_reg_dest_EX(ID_EX_ctl_EX_reg_dest),
        .i_ctl_EX_alu_src_EX(ID_EX_ctl_EX_alu_src),
        .i_ctl_EX_alu_op_EX(ID_EX_ctl_EX_ALU_op),

        .i_ctl_MEM_mem_read_EX(ID_EX_ctl_MEM_mem_read),
        .i_ctl_MEM_mem_write_EX(ID_EX_ctl_MEM_mem_write),
        .i_ctl_MEM_unsigned_EX(ID_EX_ctl_MEM_unsigned),
        .i_ctl_MEM_data_width_EX(ID_EX_ctl_MEM_data_width),

        .i_ctl_WB_mem_to_reg_EX(ID_EX_ctl_WB_mem_to_reg),
        .i_ctl_WB_reg_write_EX(ID_EX_ctl_WB_reg_write),

        .i_RA(ID_EX_RA),
        .i_RB(ID_EX_RB),
        .i_rs(ID_EX_rs),
        .i_rt(ID_EX_rt),
        .i_rd(ID_EX_rd),
        .i_funct(ID_EX_funct),
        .i_inmediato(ID_EX_inmediato),
        .i_opcode(ID_EX_opcode),
        .i_shamt(ID_EX_shamt),

        .i_forward_A(), //Forward unit
        .i_forward_B(), //Forward unit

        .i_MEM_ALU_result(EX_MEM_ALU_result), //Este es de forwarding
        .i_WB_read_data(), //Write back

        .o_ctl_MEM_mem_read_EX(),
        .o_ctl_MEM_mem_write_EX(),
        .o_ctl_MEM_unsigned_EX(),
        .o_ctl_MEM_data_width_EX(),

        .o_ctl_WB_mem_to_reg_EX(),
        .o_ctl_WB_reg_write_EX(),

        .o_ALU_result(EX_MEM_ALU_result), //Este es el que va entre EX/MEM
        .o_data_to_write(),
        .o_reg_dest()
    );

    instruction_mem u_instruction_mem (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_halt(i_halt),
    
    .i_ctl_MEM_mem_read_MEM(
    .i_ctl_MEM_mem_write_MEM(
    .i_ctl_MEM_unsigned_MEM(
    .i_ctl_MEM_data_width_MEM(

    .i_ctl_WB_mem_to_reg_MEM(
    .i_ctl_WB_reg_write_MEM(

    .i_ALU_result
    .i_data_to_write,
    .i_reg_dest,

    .o_ctl_WB_mem_to_reg_MEM,
    .o_ctl_WB_reg_write_MEM,

    .o_ALU_result()
    .o_data_readed_from_memory,
    .o_reg_dest
    );

    

endmodule
