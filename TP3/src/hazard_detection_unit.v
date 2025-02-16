module hazard_detection_unit (

    input wire i_memread_EX, // señal de lectura de memoria de la etapa de ejecución
    input wire [4:0] i_rt_EX, // dir dert de la etapa de ejecución para load hazards
    input wire [4:0] i_rt_ID, // dir de rt de la etapa de instrucción decode
    input wire [4:0] i_rs_ID, // dir de rs de la etapa de instrucción decode

    input wire [1:0] i_jumptype, // tipo de salto

    // señales para hazards de control
    input wire [4:0] i_rd_EX,   // dir de rd de la etapa de ejecución
    input wire [4:0] i_rd_MEM,  // dir de rd de la etapa de memoria
    input wire [4:0] i_rd_WB,   // dir de rd de la etapa de write back

    // señales de control
    input wire i_WB_regwrite_EX, // señal de escritura de registro de la etapa de ejecución
    input wire i_WB_regwrite_MEM, // señal de escritura de registro de la etapa de memoria
    input wire i_WB_regwrite_WB, // señal de escritura de registro de la etapa de ejecución

    output reg o_stall // señal de stall
);

initial begin
    o_stall = 0;
end


always @(*) begin

    // hazard de datos: lectura despues de escritura por sentencia load
    if (i_memread_EX && (i_rt_EX == i_rs_ID || i_rt_EX == i_rt_ID)) begin
        o_stall = 1;
    end

    // hazard de control: salto beq y bne (usan rs y rt), hasta no tener el resultado de la comparación no se sabe 
    // si se debe saltar o no
    // En el peor de los casos tenemos 3 stalls (que creo que van a ser siempre 3 igual pq la instruccion que genera el resultado para
    // comparar va pasando por cada etapa y su rd va siendo primero el rd en ex, desp el rd en mem y desp el rd en wb)
    else if (i_jumptype == 2'b01) begin
        if ( (i_WB_regwrite_EX && i_rs_ID == i_rd_EX)       ||
             (i_WB_regwrite_MEM && i_rs_ID == i_rd_MEM)     ||
             (i_WB_regwrite_WB && i_rs_ID == i_rd_WB)       ||
             (i_WB_regwrite_EX && i_rt_ID == i_rd_EX)       ||
             (i_WB_regwrite_MEM && i_rt_ID == i_rd_MEM)     ||
             (i_WB_regwrite_WB && i_rt_ID == i_rd_WB) 
            ) begin
                o_stall = 1;
            end else begin
                o_stall = 0;
            end
    end else if (i_jumptype == 2'b10) begin // salto que solo usa rs
        if ( (i_WB_regwrite_EX && i_rs_ID == i_rd_EX)       ||
             (i_WB_regwrite_MEM && i_rs_ID == i_rd_MEM)     ||
             (i_WB_regwrite_WB && i_rs_ID == i_rd_WB) 
            ) begin
                o_stall = 1;
        end else begin
            o_stall = 0;
        end
    end else begin
        o_stall = 0;
    end
end

        
    

        
        
    



endmodule