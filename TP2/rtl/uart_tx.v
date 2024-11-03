module uart_transmitter
#(
    parameter DATA_BITS = 8, // Number of data bits
    parameter STP_BITS_TICKS = 16 // one complete stop bit ( 16 ticks of oversampling clock)
)
(
    input wire i_clk, // System clock
    input wire i_reset, // Reset signal
    input wire i_tx_start, // Start transmission
    input wire i_bd_tick, // Come from baud_rate_gen module, it is the tick s_tick
    input wire [DATA_BITS-1:0] i_data, // Data to be transmitted
    output reg o_tx_transmiting, // Transmission is in progress
    output reg o_tx_done, // Transmission is done
    output wire o_tx  // Transmitted data
);

// symbolic state declaration
localparam [1:0] idle = 2'b00;
localparam [1:0] start = 2'b01;
localparam [1:0] data = 2'b10;
localparam [1:0] stop = 2'b11;

// signal declaration
reg [1:0] state, next_state; // Reg for the current state and next state
reg [3:0] tick_counter, next_tick_counter; // 7 to start, 15 to data, STP_BITS_TICKS to stop s_reg
reg [2:0] data_counter, next_data_counter; // 0 to 7 in 8 bits data n_
reg [DATA_BITS-1:0] data_reg, next_data_reg; // Data register b_
reg tx_reg, next_tx_reg; // Transmitted data register

// body
always @(posedge i_clk) begin
    
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
    
    end
end

// FSMD next-state logix & functional units
always @(*) begin
    next_state = state;
    o_tx_done = 1'b0;
    next_tick_counter = tick_counter;
    next_data_counter = data_counter;
    next_data_reg = data_reg;
    next_tx_reg = tx_reg;

    case (state)

        idle: begin
            next_tx_reg = 1'b1;
            o_tx_transmiting = 1'b0;
            if (i_tx_start) begin
                next_state = start;
                next_tick_counter = 0;
                next_data_reg = i_data;
                o_tx_transmiting = 1'b0;
            end
        end

        start: begin
            next_tx_reg = 1'b0;
            o_tx_transmiting = 1'b1;
            if(i_bd_tick) begin
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
            if(i_bd_tick) begin
                if (tick_counter == 15) begin
                    next_tick_counter = 0;
                    next_data_reg = data_reg >> 1;
                    if (data_counter == (DATA_BITS-1)) begin
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
            if(i_bd_tick) begin
                if (tick_counter == (STP_BITS_TICKS-1)) begin
                    next_state = idle;
                    o_tx_done = 1'b1;
                end else begin
                    next_tick_counter = tick_counter + 1;
                end
            end
        end

    endcase
end

// output logic
assign o_tx = tx_reg;

endmodule
