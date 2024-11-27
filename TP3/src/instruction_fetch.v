module instruction_fetch(
    input wire i_clk,
    input wire i_reset,
    input wire i_stall,
    input wire i_halt,
    input wire i_write_instruction, // para escribir en la memoria de instrucciones
    input wire [31:0] i_instruction, // instrucción a escribir
    input wire [31:0] i_address, // dirección dónde escribir la instrucción
    output reg [31:0] o_instruction, // este es el latch que se usa para guardar la instruccion
    output wire [31:0] o_pc //esto se usa para guardar la dirección de la instrucción
);

wire [31:0] instruccion_from_memory; // se usa para guardar la instruccion que se lee de la memoria
wire [31:0] address_instruction; // es la direccion que se pasa a la memoria, ya sea el pc o la direccion de escritura

assign address_instruction = i_write_instruction ? i_address : o_pc;

program_counter u_program_counter (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_jump_address(32'b0),
    .i_jump(1'b0),
    .i_stall(i_stall),
    .i_halt(i_halt),
    .o_pc(o_pc)
);

xilinx_one_port_ram_async #(
    .DATA_WIDTH(8), // 1 byte por posicion de memoria
    .ADDR_WIDTH(8) // 256 direcciones de memoria, mentenemos el byte-adreasable en multiplos de 4
) instruccion_mem (
    .i_clk(i_clk),
    .i_we(i_write_instruction),
    .i_addr(address_instruction[7:0]), 
    .i_data(i_instruction),
    .o_data(instruccion_from_memory)
);

always @(posedge i_clk) begin
    if(i_reset) begin
        o_instruction <= 32'h0;
    end else begin
        if(~i_stall && ~i_halt) begin
            o_instruction <= instruccion_from_memory;
        end
    end
end

endmodule