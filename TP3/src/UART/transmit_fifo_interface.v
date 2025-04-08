module uart_buffer
#(
    parameter DATA_BITS = 32
)
(
    input wire i_clk,
    input wire i_reset,

    // Señales hacia FIFO
    input wire i_fifo_empty,
    output reg o_fifo_rd,
    input wire [DATA_BITS-1:0] i_fifo_data,

    // Señales hacia UART transmitter
    input wire i_uart_done,
    output reg o_uart_start,
    output reg [7:0] o_uart_data
    
);

    // Estados
    localparam IDLE = 0,
               LOAD = 1,
               SEND_BYTE_0 = 2,
               SEND_BYTE_1 = 3,
               SEND_BYTE_2 = 4,
               SEND_BYTE_3 = 5,
               WAIT_DONE = 6;

    reg [2:0] state, next_state;
    reg [DATA_BITS-1:0] buffer_reg;
    reg [1:0] byte_index;
    reg [7:0] current_byte;
    reg next_fifo_rd;

    // Máquina de estados
    always @(posedge i_clk) begin
        if (i_reset) begin
            state <= IDLE;
            buffer_reg <= 0;
            byte_index <= 0;
            o_uart_data <= 0;
            o_fifo_rd <= 0;
        end else begin
            state <= next_state;
            o_fifo_rd <= next_fifo_rd;
            case (state)
                LOAD: begin
                    buffer_reg <= i_fifo_data;
                    byte_index <= 0;
                    o_uart_data <= i_fifo_data[7:0];
                end

                WAIT_DONE: begin
                    if (i_uart_done) begin
                        byte_index <= byte_index + 1;
                        case (byte_index)
                            2'd0: o_uart_data <= buffer_reg[15:8];
                            2'd1: o_uart_data <= buffer_reg[23:16];
                            2'd2: o_uart_data <= buffer_reg[31:24];
                        endcase
                    end
                end
            endcase
        end
    end

    // Lógica de transición de estado
    always @(*) begin
        // Valores por defecto
        next_state = state;
        o_uart_start = 0;
        next_fifo_rd = 0;

        case (state)
            IDLE: begin
                if (!i_fifo_empty) begin
                    next_state = LOAD;
                    next_fifo_rd = 0;
                end 
            end

            LOAD: begin
                next_state = SEND_BYTE_0;
            end

            SEND_BYTE_0: begin
                o_uart_start = 1;
                next_state = WAIT_DONE;
            end

            SEND_BYTE_1: begin
                o_uart_start = 1;
                next_state = WAIT_DONE;
            end

            SEND_BYTE_2: begin
                o_uart_start = 1;
                next_state = WAIT_DONE;
            end

            SEND_BYTE_3: begin
                o_uart_start = 1;
                next_state = WAIT_DONE;
            end

            WAIT_DONE: begin
                if (i_uart_done) begin
                    case (byte_index)
                        2'd0: next_state = SEND_BYTE_1;
                        2'd1: next_state = SEND_BYTE_2;
                        2'd2: next_state = SEND_BYTE_3;
                        2'd3: begin
                            next_state = IDLE;
                            next_fifo_rd = 1;
                        end
                    endcase
                end
            end
        endcase
    end

endmodule
