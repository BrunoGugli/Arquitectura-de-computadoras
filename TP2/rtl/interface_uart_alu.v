module interface_uart_alu
#(
    parameter NB_OP = 6, // opcode width
    parameter NB_DATA = 8, // data width
    parameter NB_FULL_DATA = 10 // full data width (opcode + data) wich came from uart
)
(
    input wire i_clk, // System clock 
    input wire i_reset, // Reset signal (maybe not used)
    input wire [NB_FULL_DATA-1:0] i_full_data, // Full data from uart
    input wire i_tx_busy, // Indicates if uart is busy
    input wire i_full_data_ready, // Indicates if full data is ready (have to be connected to rx_done)
    output reg [NB_DATA-1:0] o_operand1, // Operand 1 to send to alu
    output reg [NB_DATA-1:0] o_operand2, // Operand 2 to send to alu
    output reg [NB_OP-1:0] o_opcode, // Opcode to send to alu
    output reg o_data_ready //ver donde mandarlo
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

    // State machine logic
    always @(posedge i_clk ) begin
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

    // implementar los next :)
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
                end else begin
                    next_state = IDLE;
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
