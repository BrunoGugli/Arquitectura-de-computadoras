module instruction_wb (
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    // señales de control
    input wire i_ctl_WB_mem_to_reg_WB,
    input wire i_ctl_WB_reg_write_WB,

    // lo que viene de MEM
    input wire [31:0] i_ALU_result,
    input wire [31:0] i_data_from_memory,
    input wire [4:0] i_reg_dest,

    // salidas para las otras etapas
    output reg [31:0] o_data_to_write
);

    always @(*) begin
        if(i_reset) begin
            o_data_to_write <= 32'h0;
            o_reg_dest <= 5'b0;
        end else if(~i_halt) begin
            if (i_ctl_WB_mem_to_reg_MEM) begin
                o_data_to_write <= i_ALU_result;
            end else begin
                o_data_to_write <= i_data_from_memory;
            end
        end
    end

endmodule