module interface # (
    parameter  NB_OP = 6 ,
    parameter  NB_DATA = 8
)(
    input wire [NB_DATA-1:0] switches,       // 8 switches para operandos y operador
    input wire btn_select,           // Botón para cambiar entre operando 1, operando 2 y operador
    input wire btn_set,              // Botón para setear el valor de los switches
    input wire clk,                  // Clock
    input wire i_reset,              // Reset
    output reg signed [NB_DATA-1:0] operand1, // Primer operando de 8 bits
    output reg signed [NB_DATA-1:0] operand2, // Segundo operando de 8 bits
    output reg [NB_OP-1:0] operator         // Operador de 3 bits
);

    // Estado de selección: 0 = operando 1, 1 = operando 2, 2 = operador
    reg [1:0] select_state;

    // al tener clock se hace asignacion bloqueante
    // Inicialización
    always @(posedge clk) begin
        if (i_reset) begin
            operand1 <= 8'b0;
            operand2 <= 8'b0;
            operator <= 6'b0;
            select_state <= 2'b0;
        end
    end

    // Lógica para cambiar el estado de selección con btn_select
    always @(posedge clk) begin
        if (btn_select) begin
            select_state <= (select_state == 2'b10) ? 2'b00 : select_state + 1;
        end
    end

    // Lógica para setear el valor de los switches al operando u operador seleccionado con btn_set
    always @(posedge clk) begin
        if (btn_set) begin
            case (select_state)
                2'b00: operand1 <= switches;       // Setear operando 1
                2'b01: operand2 <= switches;       // Setear operando 2
                2'b10: operator <= switches[NB_OP-1:0];  // Setear operador (solo 3 bits)
            endcase
        end
    end

endmodule