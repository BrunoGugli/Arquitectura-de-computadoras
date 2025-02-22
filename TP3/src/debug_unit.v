module debug_unit(

    input wire i_clk,
    input wire i_reset,

    // comunicacion con el UART
    input wire i_data_ready,
    input wire [31:0] i_data,

    // comunicacion con el pipeline
    input wire i_program_end,
    input wire i_IF_ID_latch,
    input wire i_ID_EX_latch,
    input wire i_EX_MEM_latch,
    input wire i_MEM_WB_latch,
    
    output reg o_halt

)


// Estados generales
localparam [1:0] GRAL_IDLE   = 2'b0000;
localparam [1:0] GRAL_CHARGE = 2'b0001;
localparam [1:0] GRAL_CONT   = 2'b0010;
localparam [1:0] GRAL_STEP   = 2'b0011;

// Estados de carga
localparam [1:0] CH_IDLE   = 2'b0100;
localparam [1:0] CH_ASSIGN = 2'b0101;

// Estados de cont
localparam [1:0] CNT_EXEC   = 2'b0111;
localparam [1:0] CNT_READY  = 2'b1000;

// Estados de step
localparam [1:0] ST_IDLE   = 2'b1001;
localparam [1:0] ST_ASSIGN = 2'b1010;
localparam [1:0] ST_READY  = 2'b1011;

// Manejo de estados
reg [3:0] gral_state, gral_next_state;

// fixed message - GRAL
localparam [31:0] charge_mode = "\0chm";
localparam [31:0] cont_mode = "\0com";
localparam [31:0] step_mode = "\0stm";

// fixed message - CH
localparam [31:0] end_instr = 32'hffffffff;

// fixed message - ST
localparam [31:0] cancel_step = "clst";

// Flags de control
reg prog_ready;

// Manejo de estados - GRAL
always @(posedge i_clk) begin
    if (i_reset) begin
        gral_state <= GRAL_IDLE;
        o_halt <= 1'b1;
    end else begin
        gral_state <= gral_next_state;

        case (gral_next_state)
            GRAL_IDLE: begin
                o_halt <= 1'b1;
            end

            CH_IDLE: begin
                prog_ready <= 0; // creo que no hace falta esto
            end

            CH_ASSIGN: begin
                // implementar la lógica para cargar las instrucciones en la memoria de instrucciones
                if (i_data == end_instr) begin
                    prog_ready <= 1;
                end
            end

            CNT_EXEC: begin
                o_halt <= 1'b0;
            end

            
        endcase
    end
end


// Logica de la maquina de estados - GRAL
always @(*) begin
    gral_next_state = gral_state;
    case (gral_state)
        GRAL_IDLE: begin
            if (i_data_ready) begin
                if (i_data == charge_mode) begin
                    gral_next_state = CH_IDLE;
                end else if (i_data == cont_mode && prog_ready) begin
                    gral_next_state = CNT_EXEC;
                end else if (i_data == step_mode && prog_ready) begin
                    gral_next_state = ST_IDLE;
                end
            end
        end

        CH_IDLE: begin
            if (i_data_ready) begin
                gral_next_state = CH_ASSIGN;
            end
        end

        CH_ASSIGN: begin
            if (prog_ready) begin
                gral_next_state = GRAL_IDLE;
            end else begin
                gral_next_state = CH_IDLE;
            end
        end
    endcase
end






    
endmodule