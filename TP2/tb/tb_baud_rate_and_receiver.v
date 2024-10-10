module tb_top_uart();

    reg clk;
    reg reset;
    reg rx;
    wire rx_done;
    wire [7:0] data_out;

    // Clock generation
    always begin
        clk = 1'b0;
        #10 clk = 1'b1;
        #10;
    end

    // Instantiate the top module
    top_uart u_top_uart (
        .i_clk(clk),
        .i_reset(reset),
        .i_rx(rx),
        .o_rx_done(rx_done),
        .o_data(data_out)
    );

    initial begin
        // Initialize signals
        reset = 1'b1;
        rx = 1'b1; // Idle line state
        #100;
        reset = 1'b0;

        // Simulate data reception (0x55 = 01010101)
        // Start bit
        rx = 1'b0;
        #104160; // Wait for 104160 ns for 1 bit at 9600 bps (1/9600 = ~104.16 us)
        
        // Data bits (0x55 = 01010101)
        rx = 1'b1; #104160;
        rx = 1'b0; #104160;
        rx = 1'b1; #104160;
        rx = 1'b0; #104160;
        rx = 1'b1; #104160;
        rx = 1'b0; #104160;
        rx = 1'b1; #104160;
        rx = 1'b0; #104160;

        // Stop bit
        rx = 1'b1; #104160;

        // Wait for reception to complete
        #1000;

        // Check the received data
        if (data_out == 8'h55) begin
            $display("Test passed! Received data: %h", data_out);
        end else begin
            $display("Test failed! Received data: %h", data_out);
        end

        $finish;
    end
endmodule
