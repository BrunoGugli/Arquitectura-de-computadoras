module debug_unit(

    input wire i_clk,
    input wire i_reset,

    // comunicacion con el UART
    input wire i_data_ready,
    input wire [31:0] i_data,

    // comunicacion con el pipeline
    input wire i_program_end,
    input wire [63:0] i_IF_ID_latch,
    input wire [138:0] i_ID_EX_latch,
    input wire [75:0] i_EX_MEM_latch,
    input wire [70:0] i_MEM_WB_latch,
    
    output reg o_halt,
    output reg o_reset // para resetear el pipeline (en realidad es para resetear el pc) cuando se vuelve a IDLE
)


// Estados
localparam [2:0] GRAL_IDLE          = 2'b000;
localparam [2:0] CH_IDLE            = 2'b001;
localparam [2:0] CH_ASSIGN          = 2'b010;
localparam [2:0] CNT_EXEC           = 2'b011;
localparam [2:0] SEND_INFO_TO_PC    = 2'b100;
localparam [2:0] ST_IDLE            = 2'b101;
localparam [2:0] ST_ASSIGN          = 2'b110;
localparam [2:0] ST_STAGE_EXECUTED  = 2'b111;

// Manejo de estados
reg [2:0] gral_state, gral_next_state;

// fixed message - GRAL
localparam [31:0] charge_mode = "\0chm";
localparam [31:0] cont_mode = "\0com";
localparam [31:0] step_mode = "\0stm";

// fixed message - CH
localparam [31:0] end_instr = 32'hffffffff;

// fixed message - ST
localparam [31:0] cancel_step = "clst";
localparam [31:0] next_step = "nxst";

// Flags de control
reg prog_ready;
reg step_mode;
reg canceled_step;

// Manejo de estados - GRAL
always @(posedge i_clk) begin
    if (i_reset) begin
        gral_state <= GRAL_IDLE;
        o_halt <= 1'b1;
        prog_ready <= 0;
        step_mode <= 0;
        canceled_step <= 0;
    end else begin
        gral_state <= gral_next_state;

        case (gral_next_state)
            GRAL_IDLE: begin
                o_halt <= 1'b1;
                o_reset <= 1'b0; // para cuando se haga este 0, el pipeline ya va a haber leido el reset como 1 en el flanco de subida
            end

            CH_IDLE: begin
                prog_ready <= 0; // creo que no hace falta esto
            end

            CH_ASSIGN: begin
                // TODO: implementar la lógica para cargar las instrucciones en la memoria de instrucciones
                if (i_data == end_instr) begin
                    prog_ready <= 1;
                end
            end

            CNT_EXEC: begin
                o_halt <= 1'b0;
            end

            SEND_INFO_TO_PC: begin
                // TODO: implementar toda la logica de mandarle toda la info del pipeline a la pc por uart
            end

            ST_IDLE: begin
                step_mode <= 1;
            end

            ST_ASSIGN: begin
                if(i_data == next_step) begin
                    o_halt <= 1'b0;
                end else if(i_data == cancel_step) begin
                    canceled_step <= 1;
                end
            end

            ST_STAGE_EXECUTED: begin
                o_halt <= 1'b1; // acá volvemos a poner el halt en 1 para que el pipeline no siga ejecutando, ya que en este flanco ya lo leyó como 0 y ejecutó una instrucción
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
                o_reset = 1'b1;
            end else begin
                gral_next_state = CH_IDLE;
            end
        end

        CNT_EXEC: begin
            if (i_program_end) begin
                o_halt <= 1'b1; // paramos el pipeline (aca pq si lo hacemos en el proximo flanco, el pipeline va a leer el halt como 0 y va a actualizar el latch ID_EX)
                gral_next_state = SEND_INFO_TO_PC;
            end 
        end

        ST_IDLE: begin
            if (i_data_ready) begin
                gral_next_state = ST_ASSIGN;
            end
        end

        ST_ASSIGN: begin
            if (o_halt == 1'b0) begin
                gral_next_state = ST_STAGE_EXECUTED;
            end else if (canceled_step) begin
                o_reset = 1'b1;
                canceled_step <= 0;
                step_mode <= 0;
                gral_next_state = GRAL_IDLE;
            end
        end

        ST_STAGE_EXECUTED: begin
            gral_next_state = SEND_INFO_TO_PC;
        end

        SEND_INFO_TO_PC: begin
            if(~step_mode) begin // termino la ejecucion en modo continuo
                o_reset = 1'b1; // para que en el proximo ciclo de clock se resetee el pipeline
                gral_next_state = GRAL_IDLE;
            end else begin
                if (i_program_end) begin
                    o_reset = 1'b1; // para que en el proximo ciclo de clock se resetee el pipeline
                    step_mode <= 0;
                    gral_next_state = GRAL_IDLE;
                end else begin
                    gral_next_state = ST_IDLE;
                end
            end
        end
    endcase
end
endmodule
