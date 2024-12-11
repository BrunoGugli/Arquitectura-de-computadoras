module ALU #(parameter NB_OP = 6,
             parameter NB_DATA = 8,
             parameter NB_OUT = 16
)(
    input wire signed [NB_DATA-1:0] i_operand1,  // Primer operando de 8 bits
    input wire signed [NB_DATA-1:0] i_operand2,  // Segundo operando de 8 bits
    input wire [NB_OP-1:0] i_opcode,            // Código de operación de 6 bits
    output reg signed [NB_OUT-1:0] o_result    // Resultado de la operación
);
    
always @(*) begin
    case (i_opcode)
        6'b100000: o_result = i_operand1 + i_operand2; // ADD
        6'b100010: o_result = i_operand1 - i_operand2; // SUB
        6'b100100: o_result = i_operand1 & i_operand2; // AND
        6'b100101: o_result = i_operand1 | i_operand2; // OR
        6'b100110: o_result = i_operand1 ^ i_operand2; // XOR
        6'b000011: o_result = i_operand1 >>> i_operand2; // SRA
        6'b000010: o_result = i_operand1 >>  i_operand2; // SRL
        6'b100111: o_result = ~(i_operand1 | i_operand2); // NOR
        default: o_result = 8'b00000000; // Default
    endcase
end

endmodule
