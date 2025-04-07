module interface_receive_deb_unit
#(
    parameter SINGLE_DATA_WIDTH = 8,     // data width
    parameter FULL_DATA_WIDTH = 32     // full data width
)
(
    input wire i_clk,                           // System clock 
    input wire i_reset,                         // Reset signal
    input wire i_data_ready,                    // Indicates if data is ready (connected to rx_done)
    input wire [SINGLE_DATA_WIDTH-1:0] i_data,  // Full data from UART receiver
    output reg o_data_ready,                    // Data ready signal for debug unit
    output reg [FULL_DATA_WIDTH-1:0] o_data     // Full data output
);

    // States
    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] ASSIGN = 2'b01;
    localparam [1:0] READY = 2'b10;

    reg [1:0] received_bytes, next_received_bytes; // Number of bytes received

    reg [1:0] state, next_state;

    // State machine logic - Sequential block for state transitions and assignments
    always @(posedge i_clk) begin
        if (i_reset) begin
            state <= IDLE;
            o_data_ready <= 1'b0;
            o_data <= 0;
            received_bytes <= 2'b00;
            next_received_bytes <= 2'b00;
        end else begin
            state <= next_state;
            received_bytes <= next_received_bytes;

            case (next_state)
                IDLE: begin
                    o_data_ready <= 1'b0;
                end
                ASSIGN: begin
                    // Assign operands and opcode based on incoming data bits
                    case (next_received_bytes)
                        2'b00: begin
                            o_data[7:0] <= i_data; // Assign first byte
                        end
                        2'b01: begin
                            o_data[15:8] <= i_data; // Assign second byte
                        end
                        2'b10: begin
                            o_data[23:16] <= i_data; // Assign third byte
                        end
                        2'b11: begin
                            o_data[31:24] <= i_data; // Assign fourth byte
                        end
                        default: begin
                            o_data <= 0; // Default case to avoid latches
                        end
                    endcase
                end
                READY: begin
                    o_data_ready <= 1'b1;
                end
            endcase
        end
    end

    // Next state logic combinational block
    always @(*) begin
        next_state = state;
        next_received_bytes = received_bytes;

        case (state)
            IDLE: begin
                if (~i_tx_busy && i_data_ready) begin
                    next_state = ASSIGN;
                end
            end

            ASSIGN: begin
                if (received_bytes == 2'b11) begin
                    next_state = READY; // Move to READY state after assigning all bytes
                end else begin
                    next_received_bytes = received_bytes + 1; // Increment byte count
                    next_state = IDLE; // Stay in ASSIGN state until all bytes are received
                end
            end

            READY: begin
                next_state = IDLE;
            end
        endcase
    end
endmodule
