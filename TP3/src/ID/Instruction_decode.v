module instruction_decode (

    // cosas que vienen del Instruction Fetch
    input wire i_clk,
    input wire i_reset,
    input reg [31:0] i_instruction,
    input reg [31:0] i_pc,

    // cosas que van hacia el Register Bank y que vienen de la etapa de write back
    input wire i_wb_write_enable, // habilita la escritura en el banco de registros
    input wire [4:0] i_wb_write_addr, // direccion de registro a escribir
    input wire [31:0] i_wb_write_data, // dato a escribir en el registro

    //cosas del detect hazard
    input wire i_stall,

    input wire i_halt,

    // cosas que van hacia la etapa de EX
    output reg [31:0] o_RA, // dato de rs
    output reg [31:0] o_RB, // dato de rt
    output reg [ 4:0] o_rs, // direccion de rs
    output reg [ 4:0] o_rt, // direccion de rt
    output reg [ 4:0] o_rd, // direccion de rd
    output reg [ 5:0] o_funct, // codigo de operacion especifico para sumas, restas, etc
    output reg [31:0] o_inmediato, // inmediato
    output reg [ 5:0] o_opcode, // codigo de operacion para el tipo de instruccion
    output reg [ 4:0] o_shamt // indica el desplazamiento de bits

    // WB control signals
    output reg o_WB_mem_to_reg_ID,
    output reg o_WB_write_reg_ID,

    // MEM control signals
    output reg o_MEM_mem_read_ID,
    output reg o_MEM_mem_write_ID,
    output reg o_MEM_signed_ID,

    // EX control signals
    output reg o_EX_reg_dest_ID,
    output reg [1:0] o_EX_ALU_op_ID,
    output reg o_EX_ALU_src_ID,

    // jumps
    output reg o_jump,
    output reg [31:0] o_jump_address,
);

    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] RA;
    wire [4:0] RB;
    wire [31:0] inmediato;
    wire [5:0] funct;

    localparam R_TYPE = 6'b000000;

    register_bank #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(5)
    ) u_register_bank (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_write_enable(i_wb_write_enable),
        .i_read_reg1(rs),
        .i_read_reg2(rt),
        .i_write_reg(i_wb_write_addr),
        .i_data_write(i_wb_write_data),
        .o_data_read1(RA),
        .o_data_read2(RB)
    );


    // WB signals
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_WB_mem_to_reg_ID <= 0;
            o_WB_write_reg_ID <= 0;
        end else begin
            if (!halt)
        end
    end

    assign opcode = i_instruction[31:26];
    assign rs = i_instruction[25:21];
    assign rt = i_instruction[20:16];
    assign funct = i_instruction[5:0];
    assign inmediato = {16{i_instruction[15]}, i_instruction[15:0]};

endmodule