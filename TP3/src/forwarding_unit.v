module forwarding_unit (
    input wire [4:0] i_ex_mem_rd, // proviene de la etapa de memoria
    input wire [4:0] i_mem_wb_rd, // proviene de la etapa de write back
    input wire [4:0] i_id_ex_rs, // numero rs de la etapa de ejecución
    input wire [4:0] i_id_ex_rt, // numero rt de la etapa de ejecución
    input wire i_ex_mem_regwrite, // señal de escritura en el registro de la etapa de memoria
    input wire i_mem_wb_regwrite, // señal de escritura en el registro de la etapa de write back
    output reg [1:0] o_forward_a, // señal de forwarding para la entrada A
    output reg [1:0] o_forward_b // señal de forwarding para la entrada B
);

// por las dudas inicializamos las salidas para que no haya forwarding
initial begin
    o_forward_a = 2'b00;
    o_forward_b = 2'b00;
end

// forwarding para A
always @(*) begin

    if( i_ex_mem_regwrite && (i_ex_mem_rd != 5'b00000) && (i_ex_mem_rd == i_id_ex_rs) ) begin
        o_forward_a = 2'b10; // forward desde la etapa de memoria
    end
    else if( i_mem_wb_regwrite && (i_mem_wb_rd != 5'b00000) && (i_mem_wb_rd == i_id_ex_rs) ) begin
        o_forward_a = 2'b01; // forward desde la etapa de write back
    end
    else begin
        o_forward_a = 2'b00; // no hay forwarding
    end

end

// forwarding para B
always @(*) begin

    if( i_ex_mem_regwrite && (i_ex_mem_rd != 5'b00000) && (i_ex_mem_rd == i_id_ex_rt) ) begin
        o_forward_b = 2'b10; // forward desde la etapa de memoria
    end
    else if( i_mem_wb_regwrite && (i_mem_wb_rd != 5'b00000) && (i_mem_wb_rd == i_id_ex_rt) ) begin
        o_forward_b = 2'b01; // forward desde la etapa de write back
    end
    else begin
        o_forward_b = 2'b00; // no hay forwarding
    end
end



endmodule
