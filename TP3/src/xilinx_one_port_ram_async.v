module xilinx_one_port_ram_async
#(
    parameter DATA_WIDTH = 8, // 8 bit data
    parameter ADDR_WIDTH = 12 // 4k direcciones
)
(
    input wire i_clk,
    input wire i_we, // write enable
    input wire [1:0] i_writing_data_width, // 00 -> 8 bits, 01 -> 16 bits, 11 -> 32 bits
    input wire [ADDR_WIDTH-1:0] i_addr,
    input wire [DATA_WIDTH*4-1:0] i_data,
    output wire [DATA_WIDTH*4-1:0] o_data
);

    reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];

    localparam BYTE = 2'b00;
    localparam HALF_WORD = 2'b01;
    localparam WORD = 2'b11;

    always @(posedge i_clk) begin
        if(i_we) begin
            case (i_writing_data_width)
                BYTE:
                    mem[i_addr] <= i_data[7:0];
                HALF_WORD:
                    {mem[i_addr], mem[i_addr+1]} <= i_data[15:0];
                WORD:
                    {mem[i_addr], mem[i_addr+1], mem[i_addr+2], mem[i_addr+3]} <= i_data[31:0];
                default:
                    // do nothing
            endcase
        end
    end

    assign o_data = {mem[i_addr], mem[i_addr+1], mem[i_addr+2], mem[i_addr+3]};

endmodule