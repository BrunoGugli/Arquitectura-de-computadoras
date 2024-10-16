module fifo_receiver 
#(
    parameter DATA_WIDTH = 8, // data buffer bits
    parameter FIFO_DEPTH = 16 // FIFO depth
)
(
    input wire i_clk, // Clock
    input wire i_reset, // Reset
    input wire i_wr_en, // Write enable
    input wire i_rd_en, // Read enable
    input wire [DATA_WIDTH-1:0] i_wr_data, // Data to write
    output reg [DATA_WIDTH-1:0] o_rd_data, // Data to read
    output reg o_empty // FIFO empty flag
);

// Internal registers and pointers
reg [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH-1:0]; // Array of FIFO registers
reg [$clog2(FIFO_DEPTH)-1:0] wr_ptr; // write pointer
reg [$clog2(FIFO_DEPTH)-1:0] rd_ptr; // read pointer
reg [$clog2(FIFO_DEPTH):0] fifo_count; // cant of elements in the FIFO

// Next state registers
reg [$clog2(FIFO_DEPTH)-1:0] next_wr_ptr, next_rd_ptr; 
reg [$clog2(FIFO_DEPTH):0] next_fifo_count;
reg next_empty;

// Sequential logic for state update
always @(posedge i_clk) begin
    if (i_reset) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        fifo_count <= 0;
        o_empty <= 1;
    end else begin
        wr_ptr <= next_wr_ptr;
        rd_ptr <= next_rd_ptr;
        fifo_count <= next_fifo_count;
        o_empty <= next_empty;
    end
end

// Combinational logic for next state
always @(*) begin
    // Default assignments
    next_wr_ptr = wr_ptr;
    next_rd_ptr = rd_ptr;
    next_fifo_count = fifo_count;
    next_empty = o_empty;

    // Write operation
    if (i_wr_en) begin
        next_wr_ptr = (wr_ptr + 1) % FIFO_DEPTH; // Wrap around
        next_fifo_count = fifo_count + 1;
        next_empty = 0;
    end

    // Read operation
    if (i_rd_en && !o_empty) begin
        o_rd_data = fifo_mem[rd_ptr];
        next_rd_ptr = (rd_ptr + 1) % FIFO_DEPTH; // Wrap around
        next_fifo_count = fifo_count - 1;
        if (fifo_count == 1)
            next_empty = 1;
    end

    // Write data to FIFO memory
    if (i_wr_en) begin
        fifo_mem[wr_ptr] = i_wr_data;
    end
end

endmodule
