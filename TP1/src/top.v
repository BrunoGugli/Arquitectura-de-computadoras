module top_alu_interface #(
    parameter  NB_OP = 6 ,
    parameter  NB_DATA = 8,
    parameter  NB_OUT = 16
)(
    input wire [NB_DATA-1:0] i_switches,
    input wire i_btn_set_operand1,
    input wire i_btn_set_operand2,
    input wire i_btn_set_operator,
    input wire i_clk,
    input wire i_reset,
    output wire signed [NB_OUT-1:0] o_leds
);

    // internal signals to connect the interface module
    wire signed [NB_DATA-1:0] operand1;
    wire signed [NB_DATA-1:0] operand2;
    wire [NB_OP-1:0] operator;
    wire signed [NB_OUT-1:0] result;

    // interface's instantiation
    interface #(
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA)
    ) u_interface (
        .i_switches(i_switches),
        .i_btn_set_operand1(i_btn_set_operand1),
        .i_btn_set_operand2(i_btn_set_operand2),
        .i_btn_set_operator(i_btn_set_operator),
        .i_clk(i_clk),
        .i_reset(i_reset),
        .o_operand1(operand1),
        .o_operand2(operand2),
        .o_operator(operator)
    );

    // ALU's instantiation
    ALU #(
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA),
        .NB_OUT(NB_OUT)
    ) u_alu (
        .i_operand1(operand1),
        .i_operand2(operand2),
        .i_opcode(operator),
        .o_result(result)
    );

    // assign the result to the leds
    assign o_leds = result;

endmodule
