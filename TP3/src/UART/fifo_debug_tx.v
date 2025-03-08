module fifo_transmitter
#(
    parameter DATA_WIDTH = 32, // data buffer bits
    parameter FIFO_DEPTH = 75 // FIFO depth
)
(
    input wire i_clk, 
    input wire i_reset,
    input wire i_wr_en,
    input wire i_rd_en,
    input wire [DATA_WIDTH-1:0] i_wr_data,
    output reg [DATA_WIDTH-1:0] o_rd_data,
    output reg o_empty,
    output reg o_full
);

// Internal registers and pointers
reg [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH-1:0];
reg [$clog2(FIFO_DEPTH)-1:0] wr_ptr, rd_ptr;
reg [$clog2(FIFO_DEPTH):0] fifo_count;

// Next state registers
reg [$clog2(FIFO_DEPTH)-1:0] next_wr_ptr, next_rd_ptr;
reg [$clog2(FIFO_DEPTH):0] next_fifo_count;
reg next_empty;
reg next_full;

// Sequential logic for state update
always @(posedge i_clk) begin
    if (i_reset) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        fifo_count <= 0;
        o_empty <= 1;
        o_full <= 0;
    end else begin
        wr_ptr <= next_wr_ptr;
        rd_ptr <= next_rd_ptr;
        fifo_count <= next_fifo_count;
        o_empty <= next_empty;
        o_full <= next_full;

        // Perform the write operation in sequential block
        if (i_wr_en) begin
            fifo_mem[wr_ptr] <= i_wr_data;
        end
    end
end

// Combinational logic for next state
always @(*) begin
    // Default assignments
    next_wr_ptr = wr_ptr;
    next_rd_ptr = rd_ptr;
    next_fifo_count = fifo_count;
    next_empty = o_empty;
    next_full = o_full;

    // Handle simultaneous read and write
    if (i_wr_en && i_rd_en && !o_empty && !o_full) begin
        // Both pointers advance but count stays the same
        next_wr_ptr = (wr_ptr + 1) % FIFO_DEPTH;
        next_rd_ptr = (rd_ptr + 1) % FIFO_DEPTH;
        // Read data during this cycle
        o_rd_data = fifo_mem[rd_ptr];
    end else begin
        // Write operation (only if not full)
        if (i_wr_en && !o_full) begin
            next_wr_ptr = (wr_ptr + 1) % FIFO_DEPTH; 
            next_fifo_count = fifo_count + 1;
        end

        // Read operation (only if not empty)
        if (i_rd_en && !o_empty) begin
            o_rd_data = fifo_mem[rd_ptr];
            next_rd_ptr = (rd_ptr + 1) % FIFO_DEPTH;
            next_fifo_count = fifo_count - 1;
        end
    end

    // Update flags based on next count value
    next_full = (next_fifo_count == FIFO_DEPTH);
    next_empty = (next_fifo_count == 0);
end

endmodule