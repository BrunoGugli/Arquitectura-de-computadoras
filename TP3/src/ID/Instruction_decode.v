module instruction_decode (

    // cosas que vienen del Instruction Fetch
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_instruction,
    input wire [31:0] i_pc,

    // cosas que van hacia el Register Bank y que vienen de la etapa de write back
    input wire i_ctl_wb_reg_write_wb, // habilita la escritura en el banco de registros
    input wire [4:0] i_write_addr_wb, // direccion de registro a escribir
    input wire [31:0] i_write_data_wb, // dato a escribir en el registro

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
    output reg [ 4:0] o_shamt, // indica el desplazamiento de bits

    // señales de control para la etapa de WB
    output reg o_ctl_WB_mem_to_reg_ID, // 0 -> MEM to reg, 1 -> ALU to reg
    output reg o_ctl_WB_reg_write_ID,

    // señales de control para la etapa de MEM
    output reg o_ctl_MEM_mem_read_ID,
    output reg o_ctl_MEM_mem_write_ID,
    output reg o_ctl_MEM_unsigned_ID,
    output reg [1:0] o_ctl_MEM_data_width_ID , // 00 -> byte, 01 -> halfword, 11 -> word

    // señales de control para la etapa de EX
    output reg o_ctl_EX_reg_dest_ID,
    output reg [1:0] o_ctl_EX_ALU_op_ID,
    output reg o_ctl_EX_ALU_src_ID,

    // jumps
    output reg o_jump,
    output reg [31:0] o_jump_address,
    output reg [1:0] o_reg_in_jump, // 00 -> not jump, 01 -> jump with rs and rt, 10 -> jump with rs only

    // hazard unit
    output wire [4:0] o_rs_wire,
    output wire [4:0] o_rt_wire, // Estos dos para la hazard unit

    // Debug unit
    input wire [4:0] i_reg_read,
    output wire [31:0] o_reg_content,
    output wire o_program_end
);

    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [31:0] RA;
    wire [31:0] RB;
    wire [31:0] inmediato;
    wire [5:0] funct;
    wire [4:0] rs_to_bank;

    wire write_enable;

    localparam NOP = 32'h00000000;
    localparam END_INSTR = 32'hffffffff;
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
        .i_write_enable(write_enable),
        .i_read_reg1(rs_to_bank),
        .i_read_reg2(rt),
        .i_write_reg(i_write_addr_wb),
        .i_data_write(i_write_data_wb),
        .o_data_read1(RA),
        .o_data_read2(RB)
    );

    // WB signals
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_ctl_WB_mem_to_reg_ID <= 1'b0;
            o_ctl_WB_reg_write_ID <= 1'b0;
        end else begin
            if(~i_halt) begin
                if(i_stall || i_instruction == NOP) begin
                    o_ctl_WB_mem_to_reg_ID <= 1'b0;
                    o_ctl_WB_reg_write_ID <= 1'b0;
                end else begin
                    if (opcode == R_TYPE_OPCODE) begin // Tipo_R
                        o_ctl_WB_mem_to_reg_ID <= 1'b1;
                        if (funct == JR_FUNCT) begin // JR no escribe registro
                            o_ctl_WB_reg_write_ID <= 1'b0;
                        end else begin
                            o_ctl_WB_reg_write_ID <= 1'b1;
                        end
                    end else if(opcode[5:3] == 3'b100) begin // Load instructions
                        o_ctl_WB_mem_to_reg_ID <= 1'b0;
                        o_ctl_WB_reg_write_ID <= 1'b1;
                    end else if(opcode[5:3] == 3'b001 || opcode == JAL_OPCODE) begin // Inmediato instructions y JAL escribe a registro
                        o_ctl_WB_mem_to_reg_ID <= 1'b1;
                        o_ctl_WB_reg_write_ID <= 1'b1;
                    end else begin // store or branch instructions
                        o_ctl_WB_mem_to_reg_ID <= 1'b1;
                        o_ctl_WB_reg_write_ID <= 1'b0;
                    end
                end
            end
        end
    end

    // MEM signals
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_ctl_MEM_mem_read_ID <= 1'b0;
            o_ctl_MEM_mem_write_ID <= 1'b0;
            o_ctl_MEM_unsigned_ID <= 1'b0;
            o_ctl_MEM_data_width_ID <= 2'b00;
        end else begin
            if(~i_halt) begin
                if(i_stall || i_instruction == NOP) begin
                    o_ctl_MEM_mem_read_ID <= 1'b0;
                    o_ctl_MEM_mem_write_ID <= 1'b0;
                    o_ctl_MEM_unsigned_ID <= 1'b0;
                    o_ctl_MEM_data_width_ID <= 2'b00;
                end else begin
                    if(opcode[5] == 1'b1) begin // Load or store instructions
                        o_ctl_MEM_unsigned_ID <= opcode[2];
                        o_ctl_MEM_data_width_ID <= opcode[1:0];
                        if(opcode[3] == 1'b1) begin // Store
                            o_ctl_MEM_mem_read_ID <= 1'b0;
                            o_ctl_MEM_mem_write_ID <= 1'b1;
                        end else begin // Load
                            o_ctl_MEM_mem_read_ID <= 1'b1;
                            o_ctl_MEM_mem_write_ID <= 1'b0;
                        end
                    end else begin // Any other instruction
                        o_ctl_MEM_mem_read_ID <= 1'b0;
                        o_ctl_MEM_mem_write_ID <= 1'b0;
                    end
                end
            end
        end
    end

    // EX signals
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_ctl_EX_reg_dest_ID <= 1'b0;
            o_ctl_EX_ALU_op_ID <= 2'b00;
            o_ctl_EX_ALU_src_ID <= 1'b0;
        end else begin
            if(~i_halt) begin
                if(i_stall || i_instruction == NOP) begin
                    o_ctl_EX_reg_dest_ID <= 1'b0;
                    o_ctl_EX_ALU_op_ID <= 2'b00;
                    o_ctl_EX_ALU_src_ID <= 1'b0;
                end else begin
                    if(opcode == R_TYPE_OPCODE) begin // R_TYPE
                        o_ctl_EX_reg_dest_ID <= 1'b1; // dest register is rd
                        o_ctl_EX_ALU_src_ID <= 1'b0; // ALU source is register
                        if(funct == JALR_FUNCT) begin
                            o_ctl_EX_ALU_op_ID <= 2'b00; // ALU operation is add
                        end else begin
                            o_ctl_EX_ALU_op_ID <= 2'b10; // ALU operation is func field
                        end
                    end else begin
                        o_ctl_EX_reg_dest_ID <= 1'b0; // dest register is rt
                        o_ctl_EX_ALU_src_ID <= 1'b1; // ALU source is inmediato
                        if(opcode[5:3] == 3'b001) begin // Inmediato logic instructions
                            o_ctl_EX_ALU_op_ID <= 2'b11; 
                        end else if(opcode[5] == 1'b1 || opcode == JAL_OPCODE) begin // Load or store instructions
                            o_ctl_EX_ALU_op_ID <= 2'b00; // ALU operation is add
                        end else begin
                            o_ctl_EX_ALU_op_ID <= 2'b01;
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
                    o_rt <= 5'b00000; // rt is not used
                    o_RB <= 4;
                end else begin
                    o_RA <= RA;
                    o_rt <= rt;
                    o_RB <= RB;
                end

                if(opcode == JAL_OPCODE) begin
                    o_rd <= 5'b11111; // register 31
                end else begin
                    o_rd <= i_instruction[15:11];
                end

                o_opcode <= opcode;
                o_rs <= rs;
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
                    o_jump_address = i_pc + (inmediato << 2); // inmediato aligned
                end
            end

            BNE_OPCODE: begin
                o_reg_in_jump = 2'b01;
                if(RA != RB) begin
                    o_jump = 1'b1;
                    o_jump_address = i_pc + (inmediato << 2); // inmediato aligned <- hacerle tb a esto pq no se si va el +4 ahi
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
    assign inmediato = {{16{i_instruction[15]}}, i_instruction[15:0]}; // Inmediato con extension de signo
    assign o_rs_wire = rs; // para la hazard unit
    assign o_rt_wire = rt; // para la hazard unit
    assign o_program_end = (i_instruction == END_INSTR) ? 1 : 0;
    // debug
    assign rs_to_bank = i_halt ? i_reg_read : rs;
    assign o_reg_content = RA;
    assign write_enable = i_halt ? 1'b0 : i_ctl_wb_reg_write_wb;

endmodule
