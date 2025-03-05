module pipeline (

    input wire i_clk,
    input wire i_reset,
    input wire i_halt,
    input wire i_write_instruction_flag,
    input wire [31:0] i_instruction_to_write,
    input wire [31:0] i_address_to_write_inst,

    output wire [63:0] o_IF_ID_latch,
    output wire [138:0] o_ID_EX_latch,
    output wire [75:0] o_EX_MEM_latch,
    output wire [70:0] o_MEM_WB_latch,

    output wire o_program_end
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
    wire [31:0] ID_EX_inmediate;
    wire [5:0] ID_EX_opcode;
    wire [4:0] ID_EX_shamt;

    wire ID_EX_ctl_WB_mem_to_reg;
    wire ID_EX_ctl_WB_reg_write;

    wire ID_EX_ctl_MEM_mem_read;
    wire ID_EX_ctl_MEM_mem_write;
    wire ID_EX_ctl_MEM_unsigned;

    wire [1:0] ID_EX_ctl_MEM_data_width;
    wire ID_EX_ctl_EX_reg_dest;
    wire [1:0] ID_EX_ctl_EX_ALU_op;
    wire ID_EX_ctl_EX_alu_src;

    // EX/MEM
    wire [31:0] EX_MEM_ALU_result;
    wire [31:0] EX_MEM_data_to_write;
    wire [4:0]  EX_MEM_reg_dest;

    wire EX_MEM_ctl_MEM_mem_read;
    wire EX_MEM_ctl_MEM_mem_write;
    wire EX_MEM_ctl_MEM_unsigned;
    wire [1:0] EX_MEM_ctl_MEM_data_width;

    wire EX_MEM_ctl_WB_mem_to_reg;
    wire EX_MEM_ctl_WB_reg_write;

    // MEM/WB
    wire [31:0] MEM_WB_ALU_result;
    wire [31:0] MEM_WB_data_readed_from_memory;
    wire [4:0]  MEM_WB_reg_dest;

    wire MEM_WB_ctl_WB_mem_to_reg;
    wire MEM_WB_ctl_WB_reg_write;

    // WB/ID
    wire [31:0] WB_data_to_write;

    // Forwarding unit
    wire [1:0] forward_a;
    wire [1:0] forward_b;

    // Hazard unit
    wire hzrd_stall;
    wire ID_jump;
    wire [31:0] ID_jump_address;
    wire [1:0]  ID_reg_in_jump;
    wire [4:0]  ID_rs;
    wire [4:0]  ID_rt;
    wire [4:0]  EX_reg_dest;

//------------------------------------------------- INSTANCIAS ----------------------------------------------------------

    instruction_fetch u_instruction_fetch (

        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_stall(hzrd_stall),
        .i_halt(i_halt),
        .i_write_instruction_flag(i_write_instruction_flag),
        .i_jump(ID_jump),
        .i_jump_address(ID_jump_address),
        .i_instruction_to_write(i_instruction_to_write),
        .i_address_to_write_inst(i_address_to_write_inst),
        .o_instruction(IF_ID_instruction),
        .o_pc(IF_ID_pc)
    );

    instruction_decode u_instruction_decode (

        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_instruction(IF_ID_instruction),
        .i_pc(IF_ID_pc),

        .i_ctl_wb_reg_write_wb(MEM_WB_ctl_WB_reg_write),
        .i_write_addr_wb(MEM_WB_reg_dest),
        .i_write_data_wb(WB_data_to_write),
        .i_stall(hzrd_stall),
        .i_halt(i_halt),

        .o_RA(ID_EX_RA),
        .o_RB(ID_EX_RB),
        .o_rs(ID_EX_rs),
        .o_rt(ID_EX_rt),
        .o_rd(ID_EX_rd),
        .o_funct(ID_EX_funct),
        .o_inmediato(ID_EX_inmediate),
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
        .o_ctl_EX_ALU_src_ID(ID_EX_ctl_EX_alu_src),

        .o_jump(ID_jump),
        .o_jump_address(ID_jump_address),
        .o_reg_in_jump(ID_reg_in_jump),

        .o_rs_wire(ID_rs),
        .o_rt_wire(ID_rt),

        .o_program_end(o_program_end)
    );

    instruction_exec u_instruction_exec (

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
        .i_inmediate(ID_EX_inmediate),
        .i_opcode(ID_EX_opcode),
        .i_shamt(ID_EX_shamt),

        .i_forward_A(forward_a),
        .i_forward_B(forward_b),

        .i_MEM_ALU_result(EX_MEM_ALU_result),
        .i_WB_read_data(WB_data_to_write),

        .o_ctl_MEM_mem_read_EX(EX_MEM_ctl_MEM_mem_read),
        .o_ctl_MEM_mem_write_EX(EX_MEM_ctl_MEM_mem_write),
        .o_ctl_MEM_unsigned_EX(EX_MEM_ctl_MEM_unsigned),
        .o_ctl_MEM_data_width_EX(EX_MEM_ctl_MEM_data_width),

        .o_ctl_WB_mem_to_reg_EX(EX_MEM_ctl_WB_mem_to_reg),
        .o_ctl_WB_reg_write_EX(EX_MEM_ctl_WB_reg_write),

        .o_ALU_result(EX_MEM_ALU_result),
        .o_data_to_write(EX_MEM_data_to_write),
        .o_reg_dest(EX_MEM_reg_dest),
        .o_reg_dest_wire(EX_reg_dest)
    );

    instruction_mem u_instruction_mem (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_halt(i_halt),
        
        .i_ctl_MEM_mem_read_MEM(EX_MEM_ctl_MEM_mem_read),
        .i_ctl_MEM_mem_write_MEM(EX_MEM_ctl_MEM_mem_write),
        .i_ctl_MEM_unsigned_MEM(EX_MEM_ctl_MEM_unsigned),
        .i_ctl_MEM_data_width_MEM(EX_MEM_ctl_MEM_data_width),

        .i_ctl_WB_mem_to_reg_MEM(EX_MEM_ctl_WB_mem_to_reg),
        .i_ctl_WB_reg_write_MEM(EX_MEM_ctl_WB_reg_write),

        .i_ALU_result(EX_MEM_ALU_result),
        .i_data_to_write(EX_MEM_data_to_write),
        .i_reg_dest(EX_MEM_reg_dest),

        .o_ctl_WB_mem_to_reg_MEM(MEM_WB_ctl_WB_mem_to_reg),
        .o_ctl_WB_reg_write_MEM(MEM_WB_ctl_WB_reg_write),

        .o_ALU_result(MEM_WB_ALU_result),
        .o_data_readed_from_memory(MEM_WB_data_readed_from_memory),
        .o_reg_dest(MEM_WB_reg_dest)
    );

    instruction_wb u_instruction_wb (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_halt(i_halt),

        .i_ctl_WB_mem_to_reg_WB(MEM_WB_ctl_WB_mem_to_reg),
        .i_ctl_WB_reg_write_WB(MEM_WB_ctl_WB_reg_write),

        .i_ALU_result(MEM_WB_ALU_result),
        .i_data_from_memory(MEM_WB_data_readed_from_memory),
        .i_reg_dest(MEM_WB_reg_dest),

        .o_data_to_write(WB_data_to_write)
    );

    forwarding_unit u_forwarding_unit (
        .i_rd_MEM(EX_MEM_reg_dest),
        .i_rd_WB(MEM_WB_reg_dest),
        .i_rs_EX(ID_EX_rs),
        .i_rt_EX(ID_EX_rt),
        .i_regwrite_MEM(EX_MEM_ctl_WB_reg_write),
        .i_regwrite_WB(MEM_WB_ctl_WB_reg_write),
        .o_forward_a(forward_a),
        .o_forward_b(forward_b)
    );

    hazard_detection_unit u_hazard_detection_unit (
        .i_memread_EX(ID_EX_ctl_MEM_mem_read),
        .i_rt_EX(ID_EX_rt),
        .i_rt_ID(ID_rt),
        .i_rs_ID(ID_rs),

        .i_jumptype(ID_reg_in_jump),

        .i_rd_EX(EX_reg_dest),
        .i_rd_MEM(EX_MEM_reg_dest),
        .i_rd_WB(MEM_WB_reg_dest),

        .i_WB_regwrite_EX(ID_EX_ctl_WB_reg_write),
        .i_WB_regwrite_MEM(EX_MEM_ctl_WB_reg_write),
        .i_WB_regwrite_WB(MEM_WB_ctl_WB_reg_write),

        .o_stall(hzrd_stall)
    );
    
    assign o_IF_ID_latch = {IF_ID_instruction, IF_ID_pc};
    assign o_ID_EX_latch = {ID_EX_RA, ID_EX_RB, ID_EX_rs, ID_EX_rt, ID_EX_rd, ID_EX_funct, ID_EX_inmediate, ID_EX_opcode, ID_EX_shamt, ID_EX_ctl_WB_mem_to_reg, ID_EX_ctl_WB_reg_write, ID_EX_ctl_MEM_mem_read, ID_EX_ctl_MEM_mem_write, ID_EX_ctl_MEM_unsigned, ID_EX_ctl_MEM_data_width, ID_EX_ctl_EX_reg_dest, ID_EX_ctl_EX_ALU_op, ID_EX_ctl_EX_alu_src};
    assign o_EX_MEM_latch = {EX_MEM_ALU_result, EX_MEM_data_to_write, EX_MEM_reg_dest, EX_MEM_ctl_MEM_mem_read, EX_MEM_ctl_MEM_mem_write, EX_MEM_ctl_MEM_unsigned, EX_MEM_ctl_MEM_data_width, EX_MEM_ctl_WB_mem_to_reg, EX_MEM_ctl_WB_reg_write};
    assign o_MEM_WB_latch = {MEM_WB_ALU_result, MEM_WB_data_readed_from_memory, MEM_WB_reg_dest, MEM_WB_ctl_WB_mem_to_reg, MEM_WB_ctl_WB_reg_write};
    
endmodule
