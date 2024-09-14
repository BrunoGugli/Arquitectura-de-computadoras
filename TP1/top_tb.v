`timescale 1ns / 1ps

module tb_top_ALU_Interface;

    // Parameters
    parameter NB_OP = 6;
    parameter NB_DATA = 8;

    // Signals
    reg signed [NB_DATA-1:0] switches;
    reg btn_select;
    reg btn_set;
    reg clk;
    reg i_reset;

    // outputs
    wire signed [NB_DATA-1:0] o_result;

    // top's instantiation
    top_alu_interface #(
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA)
    ) u_top (
        .switches(switches),
        .btn_select(btn_select),
        .btn_set(btn_set),
        .clk(clk),
        .i_reset(i_reset),
        .o_result(o_result)
    );

    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end

    // this is very similar to the interface testbench
    initial begin 

        $display("Test started at time %t", $time);

        // set the system to a known state
        @(posedge clk);
        i_reset = 1;
        @(posedge clk);
        i_reset = 0;

        // set operand1
        @(posedge clk);
        switches = 8'b00001010;
        @(posedge clk);
        btn_set = 1;
        @(posedge clk);
        btn_set = 0;

        // Change to operand2
        @(posedge clk);
        btn_select = 1;  
        @(posedge clk);
        btn_select = 0;  

        // set operand2
        @(posedge clk);
        switches = 8'b00000101;
        @(posedge clk);
        btn_set = 1;
        @(posedge clk);
        btn_set = 0;

        // Change to operator
        @(posedge clk);
        btn_select = 1;
        @(posedge clk);
        btn_select = 0;

        // set operator
        @(posedge clk);
        switches = 6'b100000;
        @(posedge clk);
        btn_set = 1;
        @(posedge clk);
        btn_set = 0;

        // wait for the result
        #100;

        // check the result
        if (o_result !== 8'b00001111) begin
            $display("Test failed at time %t", $time);
        end else begin
            $display("Test passed at time %t", $time);
        end

        // end the simulation
        $finish;
    end

endmodule


