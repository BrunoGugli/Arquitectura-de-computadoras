module fifo_transmitter_32in_8out
#(
    parameter IN_WIDTH = 32,     // Input width (32 bits)
    parameter OUT_WIDTH = 8,     // Output width (8 bits)
    parameter FIFO_ADDR_WIDTH = 8 // FIFO depth
)
(
    input wire i_clk, 
    input wire i_reset,
    input wire i_wr,              // Write enable for 32-bit input
    input wire i_rd,              // Read enable for 8-bit output
    input wire [IN_WIDTH-1:0] i_wr_data,  // 32-bit input data
    output wire [OUT_WIDTH-1:0] o_rd_data, // 8-bit output data
    output wire o_empty,
    output wire o_full
);

    // Internal registers and pointers
    reg [IN_WIDTH-1:0] fifo_mem [2**FIFO_ADDR_WIDTH-1:0];
    reg [FIFO_ADDR_WIDTH-1:0] wr_ptr, next_wr_ptr, succ_wr_ptr;
    reg [FIFO_ADDR_WIDTH-1:0] rd_ptr, next_rd_ptr;
    reg full_reg, empty_reg, next_full, next_empty;
    
    // Byte counter to track which byte of the 32-bit word we're outputting
    reg [1:0] byte_counter, next_byte_counter;
    
    wire wr_en;
    wire rd_word_complete; // Indicates when all 4 bytes of a word have been read

    // Register file write operation (32-bit write)
    always @(posedge i_clk) begin
        if(wr_en) begin
            fifo_mem[wr_ptr] <= i_wr_data;
        end
    end

    // Update registers
    always @(posedge i_clk) begin
        if(i_reset) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            byte_counter <= 0;
            full_reg <= 0;
            empty_reg <= 1;
        end else begin
            wr_ptr <= next_wr_ptr;
            rd_ptr <= next_rd_ptr;
            byte_counter <= next_byte_counter;
            full_reg <= next_full;
            empty_reg <= next_empty;
        end
    end

    // Next state logic
    always @(*) begin
        // Default: maintain current values
        succ_wr_ptr = wr_ptr + 1;
        next_wr_ptr = wr_ptr;
        next_rd_ptr = rd_ptr;
        next_byte_counter = byte_counter;
        next_full = full_reg;
        next_empty = empty_reg;
        
        // Read logic (8-bit reads)
        if(i_rd && !empty_reg) begin
            if(byte_counter == 3) begin
                // We've read all 4 bytes, move to next word
                next_byte_counter = 0;
                next_rd_ptr = rd_ptr + 1;
                
                // Check if FIFO is now empty
                if(rd_ptr + 1 == wr_ptr) begin
                    next_empty = 1;
                end
            end else begin
                // Move to next byte in current word
                next_byte_counter = byte_counter + 1;
            end
            next_full = 0;
        end
        
        // Write logic (32-bit writes)
        if(i_wr && !full_reg) begin
            next_wr_ptr = wr_ptr + 1;
            next_empty = 0;
            
            // Check if FIFO will be full after this write
            if(next_wr_ptr == rd_ptr && (byte_counter == 0)) begin
                next_full = 1;
            end
        end
    end

    // Select correct byte from 32-bit word based on byte_counter
    wire [OUT_WIDTH-1:0] selected_byte;
    assign selected_byte = (byte_counter == 0) ? fifo_mem[rd_ptr][7:0] :
                          (byte_counter == 1) ? fifo_mem[rd_ptr][15:8] :
                          (byte_counter == 2) ? fifo_mem[rd_ptr][23:16] :
                                               fifo_mem[rd_ptr][31:24];

    // Output assignments
    assign o_rd_data = selected_byte;
    assign wr_en = i_wr & ~full_reg;
    assign o_full = full_reg;
    assign o_empty = empty_reg;

endmodule