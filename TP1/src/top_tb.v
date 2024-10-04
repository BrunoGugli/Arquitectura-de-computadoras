module tb_top_alu_interface;

    // Parameters
    parameter NB_OP = 6;
    parameter NB_DATA = 8;
    parameter NB_OUT = 16;

    // Signals
    reg [NB_DATA-1:0] switches;
    reg btn_set_operand1;
    reg btn_set_operand2;
    reg btn_set_operator;
    reg clk;
    reg reset;
    wire signed [NB_OUT-1:0] leds;

    // UUT
    top_alu_interface #(
        .NB_OP(NB_OP),
        .NB_DATA(NB_DATA),
        .NB_OUT(NB_OUT)
    ) dut (
        .i_switches(switches),
        .i_btn_set_operand1(btn_set_operand1),
        .i_btn_set_operand2(btn_set_operand2),
        .i_btn_set_operator(btn_set_operator),
        .i_clk(clk),
        .i_reset(reset),
        .o_leds(leds)
    );

    // Clock's generation
    initial begin
        clk = 0;
        forever #50 clk = ~clk; 
    end

    // Inicialización
    initial begin

        // Inicializamos señales
        switches = 0;
        btn_set_operand1 = 0;
        btn_set_operand2 = 0;
        btn_set_operator = 0;

        // Reset
        @(posedge clk);
        reset = 1;
        @(posedge clk);
        reset = 0;

        // Test: set operand1, operand2 and operator

        // set the first operand
        switches = 8'b00000101; 
        @(posedge clk);
        btn_set_operand1 = 1;    
        @(posedge clk);
        btn_set_operand1 = 0;

        #10;

        // set the second operand
        switches = 8'b00000011;  
        @(posedge clk);
        btn_set_operand2 = 1;  
        @(posedge clk);  
        btn_set_operand2 = 0;

        #10;

        // set the operator and
        switches = 6'b100000;
        @(posedge clk);    
        btn_set_operator = 1;    
        @(posedge clk);
        btn_set_operator = 0;

        #200;

        // Test: if we change a operand, the result should change

        // set the first operand
        switches = 8'b00100101;
        @(posedge clk);
        btn_set_operand1 = 1;
        @(posedge clk);
        btn_set_operand1 = 0;

        
        // wait for the result
        #20;

        // Finish the simulation
        $finish;
    end

endmodule
