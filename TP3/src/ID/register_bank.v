module register_bank #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
) (
    input wire i_clk,
    input wire i_reset,
    input wire i_write_enable,
    input wire [ADDR_WIDTH-1:0] i_read_reg1, // dirección de rs
    input wire [ADDR_WIDTH-1:0] i_read_reg2, // dirección de rt
    input wire [ADDR_WIDTH-1:0] i_write_reg, // dirección de rd
    input wire [DATA_WIDTH-1:0] i_data_write, // dato a escribir
    output reg [DATA_WIDTH-1:0] o_data_read1, // dato de rs
    output reg [DATA_WIDTH-1:0] o_data_read2 // dato de rt
);

// banco de registros de 32 registros de 32 bits
reg [DATA_WIDTH-1:0] registers [2**ADDR_WIDTH-1:0];

// inicializacion de registros
integer i;
//según el libro se lee en el flanco positivo y se escribe en el negativo
always @(nedged i_clk) begin
    if(i_reset) begin
        for(i = 0; i < 2**ADDR_WIDTH; i = i + 1) begin
            registers[i] <= 32'h0;
        end
    end else if (i_write_enable) begin
        if(i_write_reg != 5'h0) begin
            registers[i_write_reg] <= i_data_write;
        end
    end
end

// salidas
assign o_data_read1 = registers[i_read_reg1];
assign o_data_read2 = registers[i_read_reg2];

endmodule
