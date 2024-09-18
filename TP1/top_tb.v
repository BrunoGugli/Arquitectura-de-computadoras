`timescale 1ns / 1ps

module tb_top_ALU_Interface;

    // Parameters
    parameter NB_OP = 6;
    parameter NB_DATA = 8;

    // Signals
    reg [NB_DATA-1:0] switches;
    reg btn_select;
    reg btn_set;
    reg clk;
    reg i_reset;

    // Outputs
    wire [NB_DATA-1:0] leds;

    // Top's instantiation
    top_alu_interface #(
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA)
    ) u_top (
        .switches(switches),
        .btn_select(btn_select),
        .btn_set(btn_set),
        .clk(clk),
        .i_reset(i_reset),
        .leds(leds)  // Output changed from o_result to leds
    );

    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end

    initial begin 
        $display("Test started at time %t", $time);

        // Set the system to a known state
        @(posedge clk);
        i_reset = 1;
        @(posedge clk);
        i_reset = 0;

        // Set operand1
        @(posedge clk);
        switches = 8'b00001010;  
        @(posedge clk);
        btn_set = 1; // Set operand1 to 10
        @(posedge clk);
        btn_set = 0;

        // Change to operand2
        @(posedge clk);
        btn_select = 1;  
        @(posedge clk);
        btn_select = 0;  

        // Set operand2
        @(posedge clk);
        switches = 8'b00000101;  // Set operand2 to 5
        @(posedge clk);
        btn_set = 1;
        @(posedge clk);
        btn_set = 0;

        // Change to operator
        @(posedge clk);
        btn_select = 1;
        @(posedge clk);
        btn_select = 0;

        // Set operator
        @(posedge clk);
        switches = 6'b100000;  // Set operator to ADD (opcode for addition)
        @(posedge clk);
        btn_set = 1;
        @(posedge clk);
        btn_set = 0;

        // Wait for the result
        #100;

        // Check the result (expecting 15 as 10 + 5)
        if (leds !== 8'b00001111) begin
            $display("Test failed at time %t. Expected 8'b00001111 but got %b", $time, leds);
        end else begin
            $display("Test passed at time %t", $time);
        end

        // End the simulation
        $finish;
    end

endmodule
