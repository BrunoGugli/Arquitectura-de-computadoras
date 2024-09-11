// La ALU 100% combinaciona
    
module ALU (parameter = NB_OP = 6,
            parameter = NB_DATA = 8
)(
    input wire signed [NB_DATA-1:0] i_operand1,  // Primer operando de 8 bits
    input wire signed [NB_DATA-1:0] i_operand2,  // Segundo operando de 8 bits
    input wire signed [NB_OP-1:0] i_opcode,    // Código de operación de 6 bits
    reg[NB_DATA-1:0] tmp,
    output wire signed [NB_DATA-1:0] o_result // Resultado de la operación
);
    
always @(*) begin
    case (i_opcode)
        6'b100000: tmp = i_operand1 + i_operand2; // ADD
        6'b100010: tmp = i_operand1 - i_operand2; // SUB
        6'b100100: tmp = i_operand1 & i_operand2; // AND
        6'b100101: tmp = i_operand1 | i_operand2; // OR
        6'b100110: tmp = i_operand1 ^ i_operand2; // XOR
        6'b000011: tmp = i_operand1 >>> i_operand2; //SRA
        6'b000010: tmp = i_operand1 >>  i_operand2; //SRL
        6'b100111: tmp = ~(i_operand1 | i_operand2); //NOR

        default: tmp = 8'b00000000;           // Default
    endcase
end

// (solo como abstraccion para diseño) separar el circuito en cajas y tener en cuenta
// cuantas entradas y cuantas salidas tengo por caja (para los always)
// ver como ir separando en modulos, qué incluir en modulos y qué incluir en el TOP

assign o_result = tmp;
    
endmodule

