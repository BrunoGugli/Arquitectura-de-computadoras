module xilinx_one_port_ram_async
#(
    parameter DATA_WIDTH = 8, // 8 bit data
    parameter ADDR_WIDTH = 12 // 4k direcciones
)
(
    input wire i_clk,
    input wire i_we, // write enable
    //input wire [1:0] i_writing_data_width, // 00 -> 8 bits, 01 -> 16 bits, 11 -> 32 bits
    input wire [ADDR_WIDTH-1:0] i_addr,
    input wire [DATA_WIDTH*4-1:0] i_data,
    output wire [DATA_WIDTH*4-1:0] o_data
);

    reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

    always @(posedge i_clk) begin
        if(i_we) begin
            mem[i_addr] <= i_data[DATA_WIDTH-1:0];
            mem[i_addr+1] <= i_data[DATA_WIDTH*2-1:DATA_WIDTH];
            mem[i_addr+2] <= i_data[DATA_WIDTH*3-1:DATA_WIDTH*2];
            mem[i_addr+3] <= i_data[DATA_WIDTH*4-1:DATA_WIDTH*3];
        end
    end

    assign o_data = {mem[i_addr+3], mem[i_addr+2], mem[i_addr+1], mem[i_addr]};

endmodule