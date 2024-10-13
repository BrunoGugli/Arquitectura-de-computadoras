module flag_buf 
#(
    parameter DATA_WIDTH = 8 // data buffer bits
)
(
    input wire i_clk, i_reset,
    input wire i_clr_flag, i_set_flag,
    input wire [DATA_WIDTH-1:0] i_data,
    output wire o_flag,
    output wire [DATA_WIDTH-1:0] o_data
);

// signal declaration
reg [DATA_WIDTH-1:0] buf_reg, next_buf_reg;
reg flag_reg, next_flag_reg;

// body
// FF & register
always @(posedge i_clk)
    if (i_reset) 
        begin
            buf_reg <= 0;
            flag_reg <= 1'b0;
        end
    else
        begin
            buf_reg <= next_buf_reg;
            flag_reg <= next_flag_reg;
        end

// next-state logic
always @(*) begin

    next_buf_reg = buf_reg;
    next_flag_reg = flag_reg;

    if (i_set_flag) begin
        next_buf_reg = i_data;
        next_flag_reg = 1'b1;
    end
    else if (i_clr_flag) begin
        next_flag_reg = 1'b0;
    end
end

// output logic
assign o_data = buf_reg;
assign o_flag = flag_reg;

endmodule
