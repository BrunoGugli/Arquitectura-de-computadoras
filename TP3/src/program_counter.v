module program_counter(
    input wire i_clk,
    input wire i_reset,
    input wire [31:0] i_jump_address,
    input wire i_jump,
    input wire i_stall,
    input wire i_halt,
    output reg [31:0] o_pc
);

    reg first_cycle; // Indicador del primer ciclo tras el reset

    always @(posedge i_clk) begin
        if (i_reset) begin
            o_pc <= 32'h00000000;
            first_cycle <= 1'b1; // Marca que es el primer ciclo tras reset
        end else if (!i_stall && !i_halt) begin
            if (first_cycle) begin
                first_cycle <= 1'b0; // Desactiva el estado de primer ciclo
            end else if (i_jump) begin
                o_pc <= i_jump_address; // Salto a la dirección indicada
            end else begin
                o_pc <= o_pc + 32'h00000004; // Incremento normal
            end
        end
    end

endmodule
