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

    wire signed [31:0] operand_A;
    wire signed [31:0] fw_operand_B;
    wire signed [31:0] operand_B;
    wire [31:0] ALU_result_wire;
    wire [5:0] alu_opcode;

    localparam ADD_OPCODE = 6'b100000;
    localparam IDLE_OPCODE = 6'b111111;
    localparam JAL_OPCODE = 6'b000011;
    localparam R_TYPE_OPCODE = 6'b000000;
    localparam JALR_FUNCT = 6'b001001;

    // alu control
    always @(*) begin
        case(i_ctl_EX_alu_op_EX)
            2'b00: begin // Loads, stores, jalr, jal
                alu_opcode = ADD_OPCODE;
            end

            2'01: begin // Branch, no hace nada porque no se necesita ALU
                alu_opcode = IDLE_OPCODE;
            end

            2'b10: begin // Tipo R, se toma el campo funct
                alu_opcode = i_funct;
            end

            2'b11: begin // Tipo I con inmediato, se toma el opcode
                alu_opcode = i_opcode;
            end
            default: begin
                alu_opcode = IDLE_OPCODE;
            end
        endcase
    end

    // forwarding A
    always @(*) begin
        case(i_forward_A)
            2'b00: begin
                operand_A = i_RA;
            end
            2'b01: begin
                operand_A = i_WB_read_data;
            end
            2'b10: begin
                operand_A = i_MEM_ALU_result;
            end
            default: begin
                operand_A = 0;
            end
        endcase

        if(i_opcode == JAL_OPCODE || (i_opcode == R_TYPE_OPCODE && i_funct == JALR_FUNCT)) begin
            operand_A = i_RA;
        end
    end

    // forwarding B
    always @(*) begin
        case(i_forward_B)
            2'b00: begin
                fw_operand_B = i_RB;
            end
            2'b01: begin
                fw_operand_B = i_WB_read_data;
            end
            2'b10: begin
                fw_operand_B = i_MEM_ALU_result;
            end
            default: begin
                fw_operand_B = 0;
            end
        endcase

        if(i_opcode == JAL_OPCODE || (i_opcode == R_TYPE_OPCODE && i_funct == JALR_FUNCT)) begin
            fw_operand_B = i_RB;
        end
    end

    // alu src control
    always @(*) begin
        if(i_ctl_EX_alu_src_EX) begin
            operand_B = i_inmediate;
        end else begin
            operand_B = fw_operand_B;
        end
    end

    // salidas a MEM
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_ALU_result <= 32'h00000000;
            o_data_to_write <= 32'h00000000;
            o_reg_dest <= 5'b00000;
        end else if(~i_halt) begin
            // reg dest
            o_reg_dest <= i_ctl_EX_reg_dest_EX ? i_rd : i_rt;

            // Alu result
            o_ALU_result <= ALU_result_wire;

            // data to write in mem
            o_data_to_write <= fw_operand_B; // aca capaz tire error por el signed
        end
    end

    // señales de control
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_ctl_MEM_mem_read_EX <= 1'b0;
            o_ctl_MEM_mem_write_EX <= 1'b0;
            o_ctl_MEM_unsigned_EX <= 1'b0;
            o_ctl_MEM_data_width_EX <= 2'b00;
            o_ctl_WB_mem_to_reg_EX <= 1'b0;
            o_ctl_WB_reg_write_EX <= 1'b0;
        end else begin
            if(~i_halt) begin
                o_ctl_MEM_mem_read_EX       <= i_ctl_MEM_mem_read_EX;
                o_ctl_MEM_mem_write_EX      <= i_ctl_MEM_mem_write_EX;
                o_ctl_MEM_unsigned_EX       <= i_ctl_MEM_unsigned_EX;
                o_ctl_MEM_data_width_EX     <= i_ctl_MEM_data_width_EX;
                o_ctl_WB_mem_to_reg_EX      <= i_ctl_WB_mem_to_reg_EX;
                o_ctl_WB_reg_write_EX       <= i_ctl_WB_reg_write_EX;
            end
        end
    end

    // ALU
    ALU #(
        .NB_OP(6),
        .NB_DATA(32)
    ) alu_inst (
        .i_operand1(operand_A),
        .i_operand2(operand_B),
        .i_opcode(alu_opcode),
        .o_result(ALU_result_wire)
        .i_shamt(i_shamt)
    );

endmodule