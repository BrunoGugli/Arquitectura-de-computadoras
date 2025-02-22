module instruction_fetch(
    input wire i_clk,
    input wire i_reset,
    input wire i_stall,
    input wire i_halt,
    input wire i_write_instruction_flag, // para escribir en la memoria de instrucciones
    input wire i_jump,
    input wire [31:0] i_jump_address, // dirección a la que se salta
    input wire [31:0] i_instruction_to_write, // instrucción a escribir
    input wire [31:0] i_address_to_write_inst, // dirección dónde escribir la instrucción
    output reg [31:0] o_instruction, // este es el latch que se usa para guardar la instruccion
    output wire [31:0] o_pc //esto se usa para guardar la dirección de la instrucción
);

localparam ADDR_WIDTH = 12;

wire [31:0] instruction_from_memory; // se usa para guardar la instruccion que se lee de la memoria
wire [ADDR_WIDTH-1:0] address_instruction; // es la direccion que se pasa a la memoria, ya sea el pc o la direccion de escritura


program_counter u_program_counter (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_jump_address(i_jump_address),
    .i_jump(i_jump),
    .i_stall(i_stall),
    .i_halt(i_halt),
    .o_pc(o_pc)
);

xilinx_one_port_ram_async #(
    .DATA_WIDTH(8), // 1 byte por posicion de memoria
    .ADDR_WIDTH(ADDR_WIDTH) // 256 direcciones de memoria, mentenemos el byte-adreasable en multiplos de 4 ***** CAMBIAR ESTO DESPUES, ESTA ASI PARA PRUEBAS EN EL VIVADO *****
) instruccion_mem (
    .i_clk(i_clk),
    .i_we(i_write_instruction_flag),
    .i_writing_data_width(2'b11), // 32 bits
    .i_addr(address_instruction[ADDR_WIDTH-1:0]), 
    .i_data(i_instruction_to_write),
    .o_data(instruction_from_memory)
);

always @(posedge i_clk) begin
    if(i_reset) begin
        o_instruction <= 32'h0;
    end else begin
        if(~i_stall && ~i_halt) begin
            o_instruction <= instruction_from_memory;
        end
    end
end

assign address_instruction = i_write_instruction_flag ? i_address_to_write_inst : o_pc;

endmodule