module forwarding_unit (
    input wire [4:0] i_rd_MEM, // proviene de la etapa de memoria
    input wire [4:0] i_rd_WB, // proviene de la etapa de write back
    input wire [4:0] i_rs_EX, // numero rs de la etapa de ejecución
    input wire [4:0] i_rt_EX, // numero rt de la etapa de ejecución
    input wire i_regwrite_MEM, // señal de escritura en el registro de la etapa de memoria
    input wire i_regwrite_WB, // señal de escritura en el registro de la etapa de write back
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

    if( i_regwrite_MEM && (i_rd_MEM != 5'b00000) && (i_rd_MEM == i_rs_EX) ) begin
        o_forward_a = 2'b10; // forward desde la etapa de memoria
    end
    else if( i_regwrite_WB && (i_rd_WB != 5'b00000) && (i_rd_WB == i_rs_EX) ) begin
        o_forward_a = 2'b01; // forward desde la etapa de write back
    end
    else begin
        o_forward_a = 2'b00; // no hay forwarding
    end
end

// forwarding para B
always @(*) begin

    if( i_regwrite_MEM && (i_rd_MEM != 5'b00000) && (i_rd_MEM == i_rt_EX) ) begin
        o_forward_b = 2'b10; // forward desde la etapa de memoria
    end
    else if( i_regwrite_WB && (i_rd_WB != 5'b00000) && (i_rd_WB == i_rt_EX) ) begin
        o_forward_b = 2'b01; // forward desde la etapa de write back
    end
    else begin
        o_forward_b = 2'b00; // no hay forwarding
    end
end

endmodule
