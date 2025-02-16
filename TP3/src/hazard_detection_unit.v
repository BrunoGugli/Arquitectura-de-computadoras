module hazard_detection_unit (

    input wire i_id_ex_memread, // señal de lectura de memoria de la etapa de ejecución
    input wire [4:0] i_id_ex_rt, // numero rt de la etapa de ejecución para load hazards
    input wire [4:0] i_if_id_rt, // numero rt de la etapa de instrucción decode
    input wire [4:0] i_if_id_rs, // numero rs de la etapa de instrucción decode

    input wire [1:0] i_jumptype, // tipo de salto

    // señales para hazards de control
    input wire [4:0] i_ex_rd, // numero rd de la etapa de ejecución
    input wire [4:0] i_mem_rd, // numero rd de la etapa de memoria
    input wire [4:0] i_wb_rd, // numero rd de la etapa de write back

    // señales de control
    input wire i_wb_ex_regwrite, // señal de escritura de registro de la etapa de ejecución
    input wire i_wb_mem_regwrite, // señal de escritura de registro de la etapa de memoria
    input wire i_wb_wb_regwrite, // señal de escritura de registro de la etapa de ejecución

    output reg o_stall, // señal de stall

);

initial begin
    o_stall = 0;
end


always @(*) begin

    // hazard de datos: lectura despues de escritura por sentencia load
    if (i_id_ex_memread && (i_id_ex_rt == i_if_id_rs || i_id_ex_rt == i_if_id_rt)) begin
        o_stall = 1;
    end

    // hazard de control: salto beq y bne, hasta no tener el resultado de la comparación no se sabe 
    // si se debe saltar o no
    else if (i_jumptype == 2'b01) begin
        if ( (i_wb_ex_regwrite && i_if_id_rs == i_ex_rd) ||
             (i_wb_mem_regwrite && i_if_id_rs == i_mem_rd) ||
             (i_wb_wb_regwrite && i_if_id_rs == i_wb_rd) ||
             (i_wb_ex_regwrite && i_if_id_rt == i_ex_rd) ||
             (i_wb_mem_regwrite && i_if_id_rt == i_mem_rd) ||
             (i_wb_wb_regwrite && i_if_id_rt == i_wb_rd) 
            ) begin
                o_stall = 1;
        end
    end else if (i_jumptype == 2'b10) begin
    end
end

endmodule