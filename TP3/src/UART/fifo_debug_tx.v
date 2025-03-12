module fifo_transmitter
#(
    parameter DATA_WIDTH = 32, // data buffer bits
    parameter FIFO_ADDR_WIDTH = 7 // FIFO depth
)
(
    input wire i_clk, 
    input wire i_reset,
    input wire i_wr,
    input wire i_rd,
    input wire [DATA_WIDTH-1:0] i_wr_data,
    output wire [DATA_WIDTH-1:0] o_rd_data,
    output wire o_empty,
    output wire o_full
);

// Internal registers and pointers
reg [DATA_WIDTH-1:0] fifo_mem [2**FIFO_ADDR_WIDTH-1:0];
reg [FIFO_ADDR_WIDTH-1:0] wr_ptr, next_wr_ptr, succ_wr_ptr;
reg [FIFO_ADDR_WIDTH-1:0] rd_ptr, next_rd_ptr, succ_rd_ptr;
reg full_reg, empty_reg, next_full, next_empty;

wire wr_en;

// body
// register file write operation
always @(posedge i_clk) begin
    if(wr_en) begin
        fifo_mem[wr_ptr] <= i_wr_data;
    end
end

always @(posedge i_clk) begin
    if(i_reset) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        full_reg <= 0;
        empty_reg <= 1;
    end else begin
        wr_ptr <= next_wr_ptr;
        rd_ptr <= next_rd_ptr;
        full_reg <= next_full;
        empty_reg <= next_empty;
    end
end

always @(*) begin
    // succesive pointers values
    succ_wr_ptr = wr_ptr + 1;
    succ_rd_ptr = rd_ptr + 1;

    // default: keep old values
    next_wr_ptr = wr_ptr;
    next_rd_ptr = rd_ptr;
    next_full = full_reg;
    next_empty = empty_reg;

    case ({i_wr, i_rd})

        2'b01: begin // read
            if(~empty_reg) begin
                next_rd_ptr = succ_rd_ptr;
                next_full = 0;
                if(succ_rd_ptr == wr_ptr) begin
                    next_empty = 1;
                end
            end
        end

        2'b10: begin // write
            if(~full_reg) begin
                next_wr_ptr = succ_wr_ptr;
                next_empty = 0;
                if(succ_wr_ptr == rd_ptr) begin
                    next_full = 1;
                end
            end
        end

        2'b11: begin // read and write
            next_rd_ptr = succ_rd_ptr;
            next_wr_ptr = succ_wr_ptr;
        end
    endcase
end

assign o_rd_data = fifo_mem[rd_ptr];
assign wr_en = i_wr & ~full_reg;

assign o_full = full_reg;
assign o_empty = empty_reg;

endmodule