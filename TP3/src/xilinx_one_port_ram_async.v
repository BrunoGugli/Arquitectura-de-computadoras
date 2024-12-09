module xilinx_one_port_ram_async
#(
    parameter DATA_WIDTH = 8, // 8 bit data
    parameter ADDR_WIDTH = 12 // 4k direcciones
)
(
    input wire i_clk,
    input wire i_we, // write enable
    input wire [ADDR_WIDTH-1:0] i_addr,
    input wire [DATA_WIDTH*4-1:0] i_data,
    output wire [DATA_WIDTH*4-1:0] o_data
);

    // memoria de 4k direcciones de 8 bits
    reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

    always @(posedge i_clk) begin
        if(i_we) begin
            mem[i_addr] <= i_data[31:24];
            mem[i_addr+1] <= i_data[23:16];
            mem[i_addr+2] <= i_data[15:8];
            mem[i_addr+3] <= i_data[7:0];
        end
    end

    assign o_data = {mem[i_addr], mem[i_addr+1], mem[i_addr+2], mem[i_addr+3]};

endmodule