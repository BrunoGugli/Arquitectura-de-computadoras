module program_counter(
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_jump_address,
    input wire i_jump,
    input wire i_stall,
    input wire i_halt,
    output reg [31:0] o_pc
);


    always @(posedge i_clk) begin
        if (i_reset) begin
            o_pc <= 32'h00000000;
        end else if (~i_stall && ~i_halt) begin
            if (i_jump) begin
                o_pc <= i_jump_address; // Salto a la dirección indicada
            end else begin
                o_pc <= o_pc + 32'h00000004; // Incremento normal
            end
        end
    end

endmodule
