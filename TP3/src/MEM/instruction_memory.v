module instruction_exec (
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    // señales de control
    input wire i_ctl_MEM_mem_read_MEM,
    input wire i_ctl_MEM_mem_write_MEM,
    input wire i_ctl_MEM_unsigned_MEM,
    input wire [1:0] i_ctl_MEM_data_width_MEM,

    input wire i_ctl_WB_mem_to_reg_MEM,
    input wire i_ctl_WB_reg_write_MEM,

    // lo que viene de EX
    input wire [31:0] i_ALU_result,
    input wire [31:0] i_data_to_write,
    input wire [4:0] i_reg_dest,

    // señales de control output
    output reg o_ctl_WB_mem_to_reg_MEM,
    output reg o_ctl_WB_reg_write_MEM,

    // lo que va a WB
    output reg [31:0] o_ALU_result
);

    wire [31:0] data_readed_from_memory;

    // señales de control
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_ctl_WB_mem_to_reg_MEM <= 1'b0;
            o_ctl_WB_reg_write_MEM <= 1'b0;
        end else begin
            if(~i_halt) begin
                o_ctl_WB_mem_to_reg_MEM      <= i_ctl_WB_mem_to_reg_MEM;
                o_ctl_WB_reg_write_MEM       <= i_ctl_WB_reg_write_MEM;
            end
        end
    end

    // ALU
    xilinx_one_port_ram_async #(
        .DATA_WIDTH(8),
        .ADDR_WIDTH(32) // el ancho del resultado de la ALU
    ) data_memory (
        .i_clk(i_clk),
        .i_we(i_ctl_MEM_mem_write_MEM),
        .i_addr(i_ALU_result),
        .i_data(i_data_to_write),
        .o_data(o_ALU_result)
    );

endmodule
