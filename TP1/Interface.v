module interface # (
    parameter  NB_OP = 6 ,
    parameter  NB_DATA = 8
)(
    input wire [NB_DATA-1:0] switches,       // 8 switches para operandos y operador
    input wire btn_set_operand1,           // Botón para cambiar entre operando 1, operando 2 y operador
    input wire btn_set_operand2,              // Botón para setear el valor de los switches
    input wire btn_set_operator,              // Botón para setear el valor de los switches
    input wire clk,                  // Clock
    input wire i_reset,              // Reset
    output wire signed [NB_DATA-1:0] operand1, // Primer operando de 8 bits
    output wire signed [NB_DATA-1:0] operand2, // Segundo operando de 8 bits
    output wire [NB_OP-1:0] operator         // Operador de 3 bits
);

    // Estado de selección: 0 = operando 1, 1 = operando 2, 2 = operador
    reg [1:0] select_state;
    output reg signed [NB_DATA-1:0] operand1_reg; // Primer operando de 8 bits
    output reg signed [NB_DATA-1:0] operand2_reg; // Segundo operando de 8 bits
    output reg [NB_OP-1:0] operator_reg; // Operador de 3 bits

    // al tener clock se hace asignacion bloqueante
    // Inicialización
    always @(posedge clk) begin
        if (i_reset) begin
            operand1_reg <= 8'b0;
            operand2_reg <= 8'b0;
            operator_reg <= 6'b0;
        end
    end

    // Lógica para setear el valor de los switches al operando u operador seleccionado con btn_set
    always @(posedge clk) begin
        if (btn_set_operand1) begin
            operand1_reg <= switches;
        end else if (btn_set_operand2) begin
            operand2_reg <= switches;
        end else if (btn_set_operator) begin
            operator_reg <= switches;
        end
    end

    assign operand1 = operand1_reg;
    assign operand2 = operand2_reg;
    assign operator = operator_reg;

endmodule