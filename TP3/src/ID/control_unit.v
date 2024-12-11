module control_unit#(
    parameter WIDTH = 32
)(
    input wire i_clk,
    input wire i_reset,
    input wire [WIDTH-1:0] i_instruction,

    // WB signals
    output reg o_WB_mem_to_reg_ID,
    output reg o_WB_write_reg_ID,

    // MEM signals
    output reg o_MEM_mem_read_ID,
    output reg o_MEM_mem_write_ID,
    output reg o_MEM_branch_ID,
    output reg o_MEM_signed_ID,

    // EX signals
    output reg o_EX_reg_dest_ID,
    output reg [1:0] o_EX_ALU_op_ID,
    output reg o_EX_ALU_src_ID,

);
    // instrucciones tipo R (function field)
    localparam R_TYPE = 6'b000000;
    localparam SLL = 6'b000000;
    localparam SRL = 6'b000010;
    localparam SRA = 6'b000011;
    localparam SLLV = 6'b000100;
    localparam SRLV = 6'b000110;
    localparam SRAV = 6'b000111;
    localparam ADDU = 6'b100001;
    localparam SUBU = 6'b100011;
    localparam AND = 6'b100100;
    localparam OR = 6'b100101;
    localparam XOR = 6'b100110;
    localparam NOR = 6'b100111;
    localparam SLT = 6'b101010;
    localparam SLTU = 6'b101011;

    // instrucciones tipo I
    localparam LB = 6'b100000;
    localparam LH = 6'b100001;
    localparam LW = 6'b100011;
    localparam LWU = 6'b100111;
    localparam LBU = 6'b100100;
    localparam LHU = 6'b100101;
    localparam SB = 6'b101000;
    localparam SH = 6'b101001;
    localparam SW = 6'b101011;
    localparam ADDI = 6'b001000;
    localparam ADDIU = 6'b001001;
    localparam ANDI = 6'b001100;
    localparam ORI = 6'b001101;
    localparam XORI = 6'b001110;
    localparam LUI = 6'b001111;
    localparam SLTI = 6'b001010;
    localparam SLTIU = 6'b001011;
    localparam BEQ = 6'b000100;
    localparam BNE = 6'b000101;
    localparam J = 6'b000010;
    localparam JAL = 6'b000011;

    // instrucciones tipo J
    localparam JR = 6'b001000;
    localparam JALR = 6'b001001;
    
    wire opcode[5:0];

    always @(*) begin
        // WB signals
        if(opcode == R_TYPE) begin

        end

    end

    assign opcode = i_instruction[31:26];


endmodule
