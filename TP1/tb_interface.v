`timescale 1ns / 1ps 

module tb_interface;

  // Parameters
  parameter NB_OP = 6;
  parameter NB_DATA = 8;

  // Signals
  reg signed [7:0] switches;
  reg btn_select;
  reg btn_set;
  reg clk;
  reg i_reset;

  // outputs
  wire signed [NB_DATA-1:0] operand1;
  wire signed [NB_DATA-1:0] operand2;
  wire [NB_OP-1:0] operator;

  // instantiate the Unit Under Test (UUT)
    interface #(
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA)
    ) uut (
        .switches(switches),
        .btn_select(btn_select),
        .btn_set(btn_set),
        .clk(clk),
        .i_reset(i_reset),
        .operand1(operand1),
        .operand2(operand2),
        .operator(operator)
    );

  initial begin
    clk = 0;
    forever #50 clk = ~clk;
  end

  initial begin
      $display("Test started at time %t", $time);

      // set the system to a known state
      @(posedge clk);
      i_reset = 1;
      @(posedge clk);
      i_reset = 0;

      // set operand1
      @(posedge clk);
      switches = 8'b10101010;
      @(posedge clk);
      btn_set = 1;
      @(posedge clk);
      btn_set = 0;

      // Change to operand2
      @(posedge clk);
      btn_select = 1;  // Cambiar a operand2
      @(posedge clk);
      btn_select = 0;

      // set operand2
      @(posedge clk);
      switches = 8'b01010101;
      @(posedge clk);
      btn_set = 1;
      @(posedge clk);
      btn_set = 0;

      // Change to operator
      @(posedge clk);
      btn_select = 1;  // Cambiar a operator
      @(posedge clk);
      btn_select = 0;

      // set operator
      @(posedge clk);
      switches = 8'b00000001;
      @(posedge clk);
      btn_set = 1;
      @(posedge clk);
      btn_set = 0;

      // time to stabilize
      #100;

      $finish;
  end

endmodule

