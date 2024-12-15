module hazard_detection_unit (

    input wire i_id_ex_memread, // señal de lectura de memoria de la etapa de ejecución
    input wire [4:0] i_id_ex_rt, // numero rt de la etapa de ejecución para load hazards
    input wire [4:0] i_if_id_rt, // numero rt de la etapa de instrucción decode
    input wire [4:0] i_if_id_rs, // numero rs de la etapa de instrucción decode

    input wire [1:0] i_jumptype, // tipo de salto

    // señales para hazards de datos
    input wire [4:0] i_ex_rd, // numero rd de la etapa de ejecución
    input wire [4:0] i_mem_rd, // numero rd de la etapa de memoria
    input wire [4:0] i_wb_rd, // numero rd de la etapa de write back

    // señales de control
    input wire i_ex_wb_regwrite, // señal de escritura de registro de la etapa de ejecución
    input wire i_mem_wb_regwrite, // señal de escritura de registro de la etapa de memoria
    input wire i_id_ex_regwrite, // señal de escritura de registro de la etapa de ejecución

    output reg o_stall, // señal de stall

    output reg PCWrite, // señal de escritura de PC
    output reg IF_IDWrite, // señal de escritura de IF_ID
    output reg mux_control_to_zero // señal de control de mux para poner en 0 las señales de control
);

initial begin
    o_stall = 0;
end


always @(*) begin

    // hazard de datos: lectura despues de escritura por sentencia load
    if (i_id_ex_memread && (i_id_ex_rt == i_if_id_rs || i_id_ex_rt == i_if_id_rt)) begin
        o_stall = 1;
    end

    // hazard de control: salto beq y bne
    
end


endmodule