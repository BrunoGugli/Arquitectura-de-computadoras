module interface # (
    parameter  NB_OP = 6 ,
    parameter  NB_DATA = 8
)(
    input wire [NB_DATA-1:0] i_switches,       // 8 switches para operandos y operador
    input wire i_btn_set_operand1,           // Botón para cambiar entre operando 1, operando 2 y operador
    input wire i_btn_set_operand2,              // Botón para setear el valor de los switches
    input wire i_btn_set_operator,              // Botón para setear el valor de los switches
    input wire i_clk,                  // Clock
    input wire i_reset,              // Reset
    output wire signed [NB_DATA-1:0] o_operand1, // Primer operando de 8 bits
    output wire signed [NB_DATA-1:0] o_operand2, // Segundo operando de 8 bits
    output wire [NB_OP-1:0] o_operator         // Operador de 3 bits
);

    reg signed [NB_DATA-1:0] operand1_reg; // Primer operando de 8 bits
    reg signed [NB_DATA-1:0] operand2_reg; // Segundo operando de 8 bits
    reg [NB_OP-1:0] operator_reg; // Operador de 3 bits

    always @(posedge i_clk) begin
        if (i_reset) begin
            operand1_reg <= 8'b0;
            operand2_reg <= 8'b0;
            operator_reg <= 6'b0;
        end else begin
            if (i_btn_set_operand1) begin
                operand1_reg <= i_switches;
            end else if (i_btn_set_operand2) begin
                operand2_reg <= i_switches;
            end else if (i_btn_set_operator) begin
                operator_reg <= i_switches[NB_OP-1:0]; // Solo los bits necesarios para el operador
            end
        end
    end


    assign o_operand1 = operand1_reg;
    assign o_operand2 = operand2_reg;
    assign o_operator = operator_reg;

endmodule
