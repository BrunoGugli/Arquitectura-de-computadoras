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
    output reg o_WB_mem_to_reg_ID, // 0 -> MEM to reg, 1 -> ALU to reg
    output reg o_WB_write_reg_ID,

    // MEM control signals
    output reg o_MEM_mem_read_ID,
    output reg o_MEM_mem_write_ID,
    output reg o_MEM_signed_ID,
    output reg [1:0] o_MEM_data_width_ID, // 00 -> byte, 01 -> halfword, 11 -> word

    // EX control signals
    output reg o_EX_reg_dest_ID,
    output reg [1:0] o_EX_ALU_op_ID,
    output reg o_EX_ALU_src_ID,

    // jumps
    output reg o_jump,
    output reg [31:0] o_jump_address,
    output reg [1:0] o_reg_in_jump, // 00 -> not jump, 01 -> jump with rs and rt, 10 -> jump with rs only

    output wire o_halt,
);

    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] RA;
    wire [4:0] RB;
    wire [31:0] inmediato;
    wire [5:0] funct;

    localparam NOP = 32'h00000000;
    localparam HALT = 32'hffffffff;
    localparam R_TYPE_OPCODE = 6'b000000;
    localparam JAL_OPCODE = 6'b000011;
    localparam JALR_FUNCT = 6'b001001;
    localparam JR_FUNCT = 6'b001000;
    localparam BEQ_OPCODE = 6'b000100;
    localparam BNE_OPCODE = 6'b000101;
    localparam J_OPCODE = 6'b000010;

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
            o_WB_mem_to_reg_ID <= 1'b0;
            o_WB_write_reg_ID <= 1'b0;
        end else begin
            if(~i_halt) begin
                if(i_stall || i_instruction == NOP) begin
                    o_WB_mem_to_reg_ID <= 1'b0;
                    o_WB_write_reg_ID <= 1'b0;
                end else begin
                    if (opcode == R_TYPE_OPCODE || opcode == JAL_OPCODE) begin // Tipo_R y JAL escriben registro
                        if (funct == JR_FUNCT) begin // JR no escribe registro
                            o_WB_mem_to_reg_ID <= 1'b1;
                            o_WB_write_reg_ID <= 1'b0;
                        end else begin
                            o_WB_mem_to_reg_ID <= 1'b1;
                            o_WB_write_reg_ID <= 1'b1;
                        end
                    end else if(opcode[5:3] == 3'b100) begin // Load instructions
                        o_WB_mem_to_reg_ID <= 1'b0;
                        o_WB_write_reg_ID <= 1'b1;
                    end else if(opcode[5:3] == 3'b001) begin // Inmediato instructions
                        o_WB_mem_to_reg_ID <= 1'b1;
                        o_WB_write_reg_ID <= 1'b1;
                    end else begin // store or branch instructions
                        o_WB_mem_to_reg_ID <= 1'b1;
                        o_WB_write_reg_ID <= 1'b0;
                    end
                end
            end
        end
    end

    // MEM signals
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_MEM_mem_read_ID <= 1'b0;
            o_MEM_mem_write_ID <= 1'b0;
            o_MEM_signed_ID <= 1'b0;
            o_MEM_data_width_ID <= 2'b00;
        end else begin
            if(~i_halt) begin
                if(i_stall || i_instruction == NOP) begin
                    o_MEM_mem_read_ID <= 1'b0;
                    o_MEM_mem_write_ID <= 1'b0;
                    o_MEM_signed_ID <= 1'b0;
                    o_MEM_data_width_ID <= 2'b00;
                end else begin
                    if(opcode[5] == 1'b1) begin // Load or store instructions
                        o_MEM_signed_ID <= ~opcode[2];
                        o_MEM_data_width_ID <= opcode[1:0];
                        if(opcode[3] == 1'b1) begin // Store
                            o_MEM_mem_read_ID <= 1'b0;
                            o_MEM_mem_write_ID <= 1'b1;
                        end else begin // Load
                            o_MEM_mem_read_ID <= 1'b1;
                            o_MEM_mem_write_ID <= 1'b0;
                        end
                    end else begin // Any other instruction
                        o_MEM_mem_read_ID <= 1'b0;
                        o_MEM_mem_write_ID <= 1'b0;
                    end
                end
            end
        end
    end

    // EX signals
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_EX_reg_dest_ID <= 1'b0;
            o_EX_ALU_op_ID <= 2'b00;
            o_EX_ALU_src_ID <= 1'b0;
        end else begin
            if(~i_halt) begin
                if(i_stall || i_instruction == NOP) begin
                    o_EX_reg_dest_ID <= 1'b0;
                    o_EX_ALU_op_ID <= 2'b00;
                    o_EX_ALU_src_ID <= 1'b0;
                end else begin
                    if(opcode == R_TYPE_OPCODE) begin // R_TYPE
                        o_EX_reg_dest_ID <= 1'b1; // dest register is rd
                        o_EX_ALU_src_ID <= 1'b0; // ALU source is register
                        if(funct == JALR_FUNCT) begin
                            o_EX_ALU_op_ID <= 2'b00; // ALU operation is add
                        end else begin
                            o_EX_ALU_op_ID <= 2'b10; // ALU operation is func field
                        end
                    end else begin
                        o_EX_reg_dest_ID <= 1'b0; // dest register is rt
                        o_EX_ALU_src_ID <= 1'b1; // ALU source is inmediato
                        if(opcode[5:3] == 3'b001) begin // Inmediato instructions
                            o_EX_ALU_op_ID <= 2'b11; 
                        end else if(opcode[5] == 1'b1 || opcode == JAL_OPCODE) begin // Load or store instructions
                            o_EX_ALU_op_ID <= 2'b00; // ALU operation is add
                        end else begin
                            o_EX_ALU_op_ID <= 2'b01;
                        end
                    end
                end
            end
        end
    end

    // Instruction decoding
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_RA <= 32'h00000000;
            o_RB <= 32'h00000000;
            o_rs <= 5'b00000;
            o_rt <= 5'b00000;
            o_rd <= 5'b00000;
            o_funct <= 6'b000000;
            o_inmediato <= 32'h00000000;
            o_opcode <= 6'b000000;
            o_shamt <= 5'b00000;
        end else begin
            if(~i_halt) begin
                if (opcode == JAL_OPCODE || (opcode == R_TYPE_OPCODE && funct == JALR_FUNCT)) begin
                    o_RA <= i_pc;
                    o_rs <= 5'b00000; // rs is not used
                    o_RB <= 4;
                end else begin
                    o_RA <= RA;
                    o_rs <= rs;
                    o_RB <= RB;
                end

                if(opcode == JAL_OPCODE) begin
                    o_rt <= 5'b11111 // register 31
                end else begin
                    o_rt <= rt;
                end

                o_opcode <= opcode;
                o_rd <= i_instruction[15:11];
                o_shamt <= i_instruction[10:6];
                o_funct <= funct;
                o_inmediato <= inmediato;
            end
        end
    end

    // Jumps
    always @(*) begin
        o_jump_address = 0;
        o_jump = 1'b0;
        o_reg_in_jump = 2'b00;

        case (opcode)
            BEQ_OPCODE: begin
                o_reg_in_jump = 2'b01;
                if(RA == RB) begin
                    o_jump = 1'b1;
                    o_jump_address = i_pc + (inmediato << 2) + 4; // inmediato aligned
                end
            end

            BNE_OPCODE: begin
                o_reg_in_jump = 2'b01;
                if(RA != RB) begin
                    o_jump = 1'b1;
                    o_jump_address = i_pc + (inmediato << 2) + 4; // inmediato aligned
                end
            end

            J_OPCODE: begin
                o_jump = 1'b1;
                o_jump_address = {i_pc[31:28], i_instruction[25:0], 2'b00};
            end

            JAL_OPCODE: begin
                o_jump = 1'b1;
                o_jump_address = {i_pc[31:28], i_instruction[25:0], 2'b00};
            end

            R_TYPE_OPCODE: begin
                if (funct == JALR_FUNCT || funct == JR_FUNCT) begin
                    o_jump = 1'b1;
                    o_jump_address = RA;
                    o_reg_in_jump = 2'b10;
                end
            end

            default: o_jump = 1'b0;
        endcase
    end

    assign opcode = i_instruction[31:26];
    assign rs = i_instruction[25:21];
    assign rt = i_instruction[20:16];
    assign funct = i_instruction[5:0];
    assign inmediato = {16{i_instruction[15]}, i_instruction[15:0]};
    assign o_halt = (i_instruction == HALT);

endmodule