module uart_receiver
#(
    parameter DATA_BITS = 8, // Now 8 data bits
    parameter STP_BITS_TICKS = 16 // One complete stop bit (16 ticks of oversampling clock)
)
(
    input wire i_clk, // System clock
    input wire i_reset, // Reset signal
    input wire i_rx, // Received data
    input wire i_bd_tick, // Baud rate generator tick
    output reg o_rx_done, // Indicates that received data is ready
    output wire [DATA_BITS-1:0] o_data // Received data (now 8 bits)
);

// Local parameters for the state machine
localparam [1:0] idle = 2'b00;
localparam [1:0] start = 2'b01;
localparam [1:0] data = 2'b10;
localparam [1:0] stop = 2'b11;

// Registers for the state machine
reg [1:0] state, next_state; // Current state and next state
reg [3:0] tick_counter, next_tick_counter; // Tick counters
reg [4:0] data_counter, next_data_counter; // Now needs to count from 0 to 7 for 8 bits of data
reg [DATA_BITS-1:0] data_reg, next_data_reg; // Data register (now 8 bits)

// State machine
always @(posedge i_clk) begin
    if (i_reset) begin
        state <= idle;
        tick_counter <= 0;
        data_counter <= 0;
        data_reg <= 0;
    end else begin
        state <= next_state;
        tick_counter <= next_tick_counter;
        data_counter <= next_data_counter;
        data_reg <= next_data_reg;
    end
end

// Next state logic
always @(*) begin
    // Default assignments
    next_state = state;
    o_rx_done = 1'b0;
    next_tick_counter = tick_counter;
    next_data_counter = data_counter;
    next_data_reg = data_reg;

    case (state)
        idle: begin
            if (~i_rx) begin
                next_state = start;
                next_tick_counter = 0;
            end
        end

        start: begin
            if (i_bd_tick == 1) begin
                if (tick_counter == ((STP_BITS_TICKS/2)-1)) begin
                    next_state = data;
                    next_tick_counter = 0;
                    next_data_counter = 0;
                end else begin
                    next_tick_counter = tick_counter + 1;
                end
            end
        end

        data: begin
            if (i_bd_tick == 1) begin
                if (tick_counter == (STP_BITS_TICKS-1)) begin
                    next_tick_counter = 0;
                    next_data_reg = {i_rx, data_reg[DATA_BITS-1:1]};
                    if (data_counter == DATA_BITS-1) begin
                        next_state = stop;
                    end else begin
                        next_data_counter = data_counter + 1;
                    end
                end else begin
                    next_tick_counter = tick_counter + 1;
                end
            end
        end

        stop: begin
            if (i_bd_tick == 1) begin
                if (tick_counter == (STP_BITS_TICKS-1)) begin
                    next_state = idle;
                    o_rx_done = 1'b1;
                end else begin
                    next_tick_counter = tick_counter + 1;
                end
            end
        end

    endcase
end

// Output data
assign o_data = data_reg;

endmodule
