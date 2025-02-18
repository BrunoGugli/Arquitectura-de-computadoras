module ALU #(parameter NB_OP = 6,
             parameter NB_DATA = 32,
)(
    input wire signed [NB_DATA-1:0] i_operand1,  // Primer operando de 8 bits
    input wire signed [NB_DATA-1:0] i_operand2,  // Segundo operando de 8 bits
    input wire [NB_OP-1:0] i_opcode,            // Código de operación de 6 bits
    input wire [4:0] i_shamt,                    // Cantidad de desplazamiento
    output reg [NB_DATA-1:0] o_result    // Resultado de la operación
);

localparam ADD_OPCODE   = 6'b100000;
localparam IDLE_OPCODE  = 6'b111111;
localparam SLL_OPCODE   = 6'b000000;
localparam SRL_OPCODE   = 6'b000010;
localparam SRA_OPCODE   = 6'b000011;
localparam SLLV_OPCODE  = 6'b000100;
localparam SRLV_OPCODE  = 6'b000110;
localparam SRAV_OPCODE  = 6'b000111;
localparam ADDU_OPCODE  = 6'b100001;
localparam SUBU_OPCODE  = 6'b100011;
localparam AND_OPCODE   = 6'b100100;
localparam OR_OPCODE    = 6'b100101;
localparam XOR_OPCODE   = 6'b100110;
localparam NOR_OPCODE   = 6'b100111;
localparam SLT_OPCODE   = 6'b101010;
localparam SLTU_OPCODE  = 6'b101011;

localparam ADDI_OPCODE  = 6'b001000;
localparam ADDIU_OPCODE = 6'b001001;
localparam SLTI_OPCODE  = 6'b001010;
localparam SLTIU_OPCODE = 6'b001011;
localparam ANDI_OPCODE  = 6'b001100;
localparam ORI_OPCODE   = 6'b001101;
localparam XORI_OPCODE  = 6'b001110;
localparam LUI_OPCODE   = 6'b001111;
    
always @(*) begin
    case (i_opcode)
        ADD_OPCODE:o_result = i_operand1 + i_operand2;
        IDLE_OPCODE:o_result = 0;
        SLL_OPCODE:o_result = i_operand1 << i_shamt;
        SRL_OPCODE:o_result = i_operand1 >> i_shamt;
        SRA_OPCODE:o_result = i_operand1 >>> i_shamt;
        SLLV_OPCODE:o_result = i_operand1 << i_operand2;
        SRLV_OPCODE:o_result = i_operand1 >> i_operand2;
        SRAV_OPCODE:o_result = i_operand1 >>> i_operand2;
        ADDU_OPCODE:o_result = $unsigned(i_operand1) + $unsigned(i_operand2);
        SUBU_OPCODE:o_result = $unsigned(i_operand1) - $unsigned(i_operand2);
        AND_OPCODE:o_result = i_operand1 & i_operand2;
        OR_OPCODE:o_result = i_operand1 | i_operand2;
        XOR_OPCODE:o_result = i_operand1 ^ i_operand2;
        NOR_OPCODE:o_result = ~(i_operand1 | i_operand2);
        SLT_OPCODE:o_result = (i_operand1 < i_operand2) ? 1 : 0;
        SLTU_OPCODE:o_result = ($unsigned(i_operand1) < $unsigned(i_operand2)) ? 1 : 0;

        ADDI_OPCODE:o_result = i_operand1 + i_operand2;
        ADDIU_OPCODE:o_result = $unsigned(i_operand1) + $unsigned(i_operand2);
        SLTI_OPCODE:o_result = (i_operand1 < i_operand2) ? 1 : 0;
        SLTIU_OPCODE:o_result = ($unsigned(i_operand1) < $unsigned(i_operand2)) ? 1 : 0;
        ANDI_OPCODE:o_result = i_operand1 & i_operand2;
        ORI_OPCODE:o_result = i_operand1 | i_operand2;
        XORI_OPCODE: o_result = i_operand1 ^ i_operand2;
        LUI_OPCODE: o_result = {i_operand2[15:0], 16'b0}
        default: o_result = 0;
    endcase
end

endmodule
