module instruction_decode (

    // cosas que vienen del Instruction Fetch
    input wire i_clk,
    input wire i_reset,
    input reg [31:0] i_instruction,
    input reg [31:0] i_pc,

    // cosas que van hacia el Register Bank y que vienen de la etapa de write back
    input wire i_wb_write_enable, // habilita la escritura en el banco de registros
    input wire [4:0] i_wb_write_addr, // direccion de registro a escribir
    input wire [31:0] i_wb_write_data, // dato a escribir en el registro

    //cosas del detect hazard
    input wire i_stall,
    input wire i_halt,

    // cosas que van hacia la etapa de EX
    output reg [31:0] o_pc, // direccion de la instruccion
    output reg [31:0] o_RA, // dato de rs
    output reg [31:0] o_RB, // dato de rt
    output reg [ 4:0] o_rs, // direccion de rs
    output reg [ 4:0] o_rt, // direccion de rt
    output reg [ 4:0] o_rd, // direccion de rd
    output reg [ 5:0] o_funct, // codigo de operacion especifico para sumas, restas, etc
    output reg [31:0] o_inmediato, // inmediato
    output reg [ 5:0] o_opcode, // codigo de operacion para el tipo de instruccion
    output reg [ 4:0] o_shamt // indica el desplazamiento de bits









)

endmodule