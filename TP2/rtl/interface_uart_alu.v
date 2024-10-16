module interface_uart_alu
#(
    parameter NB_OP = 6,
    parameter NB_DATA = 8,
    parameter NB_FULL_DATA = 10
)
(
    input wire i_clk,
    input wire i_reset,
    input wire [NB_FULL_DATA-1:0] i_full_data,
    input wire i_tx_busy,
    input wire i_full_data_ready,
    output reg [NB_DATA-1:0] o_operand1,
    output reg [NB_DATA-1:0] o_operand2,
    output reg [NB_OP-1:0] o_opcode,
    output reg o_data_ready //ver donde mandarlo
);

    // Estados de la máquina de estados
    reg [1:0] IDLE;
    reg [1:0] ASSIGN;
    reg [1:0] READY;

    reg state, next_state;

    // Flags de operandos y opcode
    reg operand1_ready;
    reg operand2_ready;
    reg opcode_ready;

    // Lógica de la máquina de estados
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            state <= IDLE;
            operand1_ready <= 1'b0;
            operand2_ready <= 1'b0;
            opcode_ready <= 1'b0;
            o_data_ready <= 1'b0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                o_data_ready = 1'b0;
                if (~i_tx_busy & i_full_data_ready) begin
                    next_state = ASSIGN;
                end
            end
            ASSIGN: begin
                case (i_full_data[NB_FULL_DATA-1:NB_FULL_DATA-2])
                    2'b00: begin
                        o_operand1 = i_full_data[NB_DATA-1:0];
                        operand1_ready = 1'b1;
                    end
                    2'b01: begin
                        o_operand2 = i_full_data[NB_DATA-1:0];
                        operand2_ready = 1'b1;
                    end
                    2'b10: begin
                        o_opcode = i_full_data[NB_OP-1:0];
                        opcode_ready = 1'b1;
                    end
                endcase
                if (operand1_ready & operand2_ready & opcode_ready) begin
                    next_state = READY;
                end
            end
            READY: begin
                o_data_ready = 1'b1;
                operand1_ready = 1'b0;
                operand2_ready = 1'b0;
                opcode_ready = 1'b0;
                next_state = IDLE;
            end
        endcase
    end
endmodule
