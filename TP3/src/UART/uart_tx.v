module uart_transmitter
#(
    parameter DATA_BITS = 32,         // Number of data bits
    parameter STP_BITS_TICKS = 16    // One complete stop bit (16 ticks of oversampling clock)
)
(
    input wire i_clk,                // System clock
    input wire i_reset,              // Reset signal
    input wire i_tx_start,           // Start transmission
    input wire i_bd_tick,            // Tick signal from baud_rate_gen module
    input wire [DATA_BITS-1:0] i_data, // Data to be transmitted
    output reg o_tx_transmiting,     // Transmission in progress indicator
    output wire o_tx                 // Transmitted data output
);

    // Symbolic state declaration
    localparam [1:0] idle = 2'b00;
    localparam [1:0] start = 2'b01;
    localparam [1:0] data = 2'b10;
    localparam [1:0] stop = 2'b11;

    // Signal declaration
    reg [1:0] state, next_state;
    reg [3:0] tick_counter, next_tick_counter;
    reg [4:0] data_counter, next_data_counter;
    reg [DATA_BITS-1:0] data_reg, next_data_reg;
    reg tx_reg, next_tx_reg;

    reg next_tx_transmiting;  // Intermediate signal for o_tx_transmiting

    // Body
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            state <= idle;
            tick_counter <= 0;
            data_counter <= 0;
            data_reg <= 0;
            tx_reg <= 1;
            o_tx_transmiting <= 1'b0;
        end else begin
            state <= next_state;
            tick_counter <= next_tick_counter;
            data_counter <= next_data_counter;
            data_reg <= next_data_reg;
            tx_reg <= next_tx_reg;
            o_tx_transmiting <= next_tx_transmiting;  // Update transmiting status
        end
    end

    // FSMD next-state logic & functional units
    always @(*) begin
        next_state = state;
        next_tick_counter = tick_counter;
        next_data_counter = data_counter;
        next_data_reg = data_reg;
        next_tx_reg = tx_reg;
        next_tx_transmiting = o_tx_transmiting;

        case (state)
            idle: begin
                next_tx_reg = 1'b1;
                next_tx_transmiting = 1'b0;
                if (i_tx_start) begin
                    next_state = start;
                    next_tick_counter = 0;
                    next_data_reg = i_data;
                    next_tx_transmiting = 1'b1;
                end
            end

            start: begin
                next_tx_reg = 1'b0;
                next_tx_transmiting = 1'b1;
                if (i_bd_tick) begin
                    if (tick_counter == 15) begin
                        next_state = data;
                        next_tick_counter = 0;
                        next_data_counter = 0;
                    end else begin
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end

            data: begin
                next_tx_reg = data_reg[0];
                if (i_bd_tick) begin
                    if (tick_counter == 15) begin
                        next_tick_counter = 0;
                        next_data_reg = data_reg >> 1;
                        if (data_counter == (DATA_BITS - 1)) begin
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
                next_tx_reg = 1'b1;
                if (i_bd_tick) begin
                    if (tick_counter == (STP_BITS_TICKS - 1)) begin
                        next_state = idle;
                        next_tx_transmiting = 1'b0;
                    end else begin
                        next_tick_counter = tick_counter + 1;
                    end
                end
            end

        endcase
    end

    // Output logic
    assign o_tx = tx_reg;

endmodule
