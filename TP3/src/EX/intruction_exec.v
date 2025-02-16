module instruction_exec (
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    // señales de control
    input wire i_ctl_EX_reg_dest_EX,
    input wire i_ctl_EX_alu_src_EX,
    input wire [1:0] i_ctl_EX_alu_op_EX,

    input wire i_ctl_MEM_mem_read_EX,
    input wire i_ctl_MEM_mem_write_EX,
    input wire i_ctl_MEM_unsigned_EX,
    input wire [1:0] i_ctl_MEM_data_width_EX,

    input wire i_ctl_WB_mem_to_reg_EX,
    input wire i_ctl_WB_reg_write_EX,

    // lo que viene del ID
    input wire [31:0] i_RA,
    input wire [31:0] i_RB,
    input wire [4:0] i_rs,
    input wire [4:0] i_rt,
    input wire [4:0] i_rd,
    input wire [5:0] i_funct,
    input wire [31:0] i_inmediate,
    input wire [5:0] i_opcode,
    input wire [4:0] i_shamt,

    // de la forward unit
    input wire [1:0] i_forward_A,
    input wire [1:0] i_forward_B,

    // datos de mem y write-back
    input wire [31:0] i_MEM_ALU_result,
    input wire [31:0] i_WB_read_data,

    // señales de control output
    input reg o_ctl_MEM_mem_read_EX,
    input reg o_ctl_MEM_mem_write_EX,
    input reg o_ctl_MEM_unsigned_EX,
    input reg [1:0] o_ctl_MEM_data_width_EX,
    input reg o_ctl_WB_mem_to_reg_EX,
    input reg o_ctl_WB_reg_write_EX,

    // lo que va a MEM
    output reg [31:0] o_ALU_result,
    output reg [31:0] o_data_to_write,
    output reg [4:0] o_reg_dest,
);

endmodule