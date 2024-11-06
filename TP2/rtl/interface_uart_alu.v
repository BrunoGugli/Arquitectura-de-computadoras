module interface_uart_alu
#(
    parameter NB_OP = 6,       // opcode width
    parameter NB_DATA = 8,     // data width
    parameter NB_FULL_DATA = 10 // full data width (opcode + data) which came from uart
)
(
    input wire i_clk,              // System clock 
    input wire i_reset,            // Reset signal
    input wire [NB_FULL_DATA-1:0] i_full_data,  // Full data from UART
    input wire i_tx_busy,           // Indicates if UART is busy
    input wire i_full_data_ready,    // Indicates if full data is ready (connected to rx_done)
    output reg [NB_DATA-1:0] o_operand1, // Operand 1 to send to ALU
    output reg [NB_DATA-1:0] o_operand2, // Operand 2 to send to ALU
    output reg [NB_OP-1:0] o_opcode,     // Opcode to send to ALU
    output reg o_data_ready             // Data ready signal for ALU
);

    // States
    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] ASSIGN = 2'b01;
    localparam [1:0] READY = 2'b10;

    reg [1:0] state, next_state;

    // Flags to indicate if the data is ready
    reg operand1_ready;
    reg operand2_ready;
    reg opcode_ready;

    // State machine logic - Sequential block for state transitions and assignments
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            state <= IDLE;
            operand1_ready <= 1'b0;
            operand2_ready <= 1'b0;
            opcode_ready <= 1'b0;
            o_data_ready <= 1'b0;
            o_operand1 <= 0;
            o_operand2 <= 0;
            o_opcode <= 0;
        end else begin
            state <= next_state;

            case (next_state)
                IDLE: begin
                    o_data_ready <= 1'b0;
                end
                ASSIGN: begin
                    // Assign operands and opcode based on incoming data bits
                    if (i_full_data[NB_FULL_DATA-1:NB_FULL_DATA-2] == 2'b00) begin
                        o_operand1 <= i_full_data[NB_DATA-1:0];
                        operand1_ready <= 1'b1;
                    end
                    else if (i_full_data[NB_FULL_DATA-1:NB_FULL_DATA-2] == 2'b01) begin
                        o_operand2 <= i_full_data[NB_DATA-1:0];
                        operand2_ready <= 1'b1;
                    end
                    else if (i_full_data[NB_FULL_DATA-1:NB_FULL_DATA-2] == 2'b10) begin
                        o_opcode <= i_full_data[NB_OP-1:0];
                        opcode_ready <= 1'b1;
                    end
                end
                READY: begin
                    o_data_ready <= 1'b1;
                    // Reset flags after indicating data is ready
                    operand1_ready <= 1'b0;
                    operand2_ready <= 1'b0;
                    opcode_ready <= 1'b0;
                end
            endcase
        end
    end

    // Next state logic combinational block
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (~i_tx_busy && i_full_data_ready) begin
                    next_state = ASSIGN;
                end
            end

            ASSIGN: begin
                if (operand1_ready && operand2_ready && opcode_ready) begin
                    next_state = READY;
                end else begin
                    next_state = IDLE;
                end
            end

            READY: begin
                next_state = IDLE;
            end
        endcase
    end
endmodule
