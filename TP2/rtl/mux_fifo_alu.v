module fifo_rx_alu
#(
    parameter NB_OP = 6,
    parameter NB_DATA = 8,
    parameter NB_FULL_DATA = 10,
)
(
    input wire i_clk, i_reset,
    input wire [NB_FULL_DATA-1:0] i_full_data,
    input wire i_tx_busy,
    output wire [NB_DATA-1:0] o_operand1,
    output wire [NB_DATA-1:0] o_operand2,
    output wire [NB_OP-1:0] o_opcode,
    output wire data_ready
)

reg operand1_ready;
reg operand2_ready;
reg opcode_ready;

always @(posedge clk) begin
    if (~i_tx_busy) begin
        case (i_full_data[NB_FULL_DATA-1:NB_FULL_DATA-2]) // 2 MSB from full data to select between operand1, operand2 and opcode
            2'b00:  o_operand1 = i_full_data[NB_DATA-1:0]; // assign 8 LSB from full data to operand1
                    operand1_ready = 1'b1;
            2'b01:  o_operand2 = i_full_data[NB_DATA-1:0]; // assign 8 LSB from full data to operand2
                    operand2_ready = 1'b1;
            2'b10:  o_opcode = i_full_data[NB_OP-1:0]; // assign 6 LSB from full data to opcode
                    opcode_ready = 1'b1;
            default: begin
                o_operand1 = {NB_DATA{1'b0}};
                o_operand2 = {NB_DATA{1'b0}};
                o_opcode = {NB_OP{1'b0}};
            end
        endcase
    end
end

assign data_ready = operand1_ready & operand2_ready & opcode_ready;

endmodule
