module program_counter(
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_jump_address, // esto es 21 bits en la instruccion, hay que ver como extender
    input wire i_jump, // indica si se debe realizar un salto
    input wire i_stall, // indica si se debe detener el contador por un problema hazard
    input wire i_halt, // indica si el procesador esta detenido por un halt 
    output reg [31:0] o_pc // direccion de la siguiente instruccion
);

always @(posedge i_clk) begin
    if(i_reset) begin
        o_pc <=  32'h00000000;
    end else if (!i_stall && !i_halt) begin
        if(i_jump) begin
            o_pc <= i_jump_address; // proxima instruccion es la direccion de salto
        end else begin
            o_pc <= o_pc + 32'h00000004;
        end
    end

end

endmodule