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
    input wire i_ID_jump,
    input wire [31:0] i_ID_jump_address,
    input wire [4:0] i_ID_rs,
    input wire [4:0] i_ID_rt,
    input wire [4:0] i_EX_reg_dest,
    input wire [31:0] i_register_content,
    
    output reg o_halt,
    output reg o_reset, // para resetear el pipeline (en realidad es para resetear el pc) cuando se vuelve a IDLE
    output reg o_stall,
    output reg o_write_instruction_flag,
    output reg [31:0] o_instruction_to_write,
    output reg [31:0] o_address_to_write_inst,
    output reg [4:0] o_reg_add_to_read
)


// Estado3
localparam [3:0] GRAL_IDLE          = 4'b0000;
localparam [3:0] LO_IDLE            = 4'b0001;
localparam [3:0] LO_ASSIGN          = 4'b0010;
localparam [3:0] LO_INSTR_LOADED    = 4'b0011;
localparam [3:0] CNT_EXEC           = 4'b0100;
localparam [3:0] SEND_INFO_TO_PC    = 4'b0101;
localparam [3:0] ST_IDLE            = 4'b0110;
localparam [3:0] ST_ASSIGN          = 4'b0111;
localparam [3:0] ST_STAGE_EXECUTED  = 4'b1000;

// Manejo de estados
reg [3:0] gral_state, gral_next_state;

// fixed message - GRAL
localparam [31:0] load_mode_msg = "\0lom";
localparam [31:0] cont_mode_msg = "\0com";
localparam [31:0] step_mode_msg = "\0stm";

// fixed message - LO
localparam [31:0] end_instr = 32'hffffffff;

// fixed message - ST
localparam [31:0] cancel_step_msg = "clst";
localparam [31:0] next_step_msg = "nxst";

// Flags de control
reg prog_ready;
reg step_mode;
reg canceled_step;
reg [1:0] last_intr_count;
reg last_instr_received;

reg [31:0] registers [31:0];

// Manejo de estados - GRAL
always @(posedge i_clk) begin
    if (i_reset) begin
        gral_state <= GRAL_IDLE;
        o_halt <= 1'b1;
        prog_ready <= 0;
        step_mode <= 0;
        canceled_step <= 0;
        last_intr_count <= 2'b00;
        o_stall <= 1'b0;
        o_write_instruction_flag <= 1'b0;
        o_instruction_to_write <= 32'h00000000;
        o_address_to_write_inst <= 32'h00000000;
        last_instr_received <= 0;
    end else begin
        gral_state <= gral_next_state;

        case (gral_next_state)
            GRAL_IDLE: begin
                o_halt <= 1'b1;
                o_reset <= 1'b0; // para cuando se haga este 0, el pipeline ya va a haber leido el reset como 1 en el flanco de subida
                o_stall <= 1'b0;
                last_instr_received <= 0;   // la reiniciamos por si venimos de LO_INTR_LOADED
                canceled_step <= 0;         // la reiniciamos por si venimos de ST_ASSIGN
                step_mode <= 0;             // la reiniciamos por si venimos de ST_ASSIGN
            end

            LO_IDLE: begin
                prog_ready <= 0;
            end

            LO_ASSIGN: begin
                o_write_instruction_flag <= 1'b1;
                o_instruction_to_write <= i_data;
                if (i_data == end_instr) begin
                    last_instr_received <= 1;
                end
            end

            LO_INSTR_LOADED: begin
                o_write_instruction_flag <= 1'b0;
                if(last_instr_received) begin
                    o_address_to_write_inst <= 32'h00000000;
                    prog_ready <= 1;
                end else begin
                    o_address_to_write_inst <= o_address_to_write_inst + 4;
                end
            end

            CNT_EXEC: begin
                o_halt <= 1'b0;
                if (i_program_end) begin // si la instr que esta en decode es la end, debo dejar pasar 3 ciclos más para que la ultima instr eferctiva termine de ejecutarse (salga del pipeline)
                    last_intr_count <= last_intr_count + 1;
                end
            end

            SEND_INFO_TO_PC: begin
                // TODO: implementar toda la logica de mandarle toda la info del pipeline a la pc por uart
                
            end

            ST_IDLE: begin
                step_mode <= 1;
            end

            ST_ASSIGN: begin
                if(i_data == next_step_msg) begin
                    o_halt <= 1'b0;
                end else if(i_data == cancel_step_msg) begin
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
                if (i_data == load_mode_msg) begin
                    gral_next_state = LO_IDLE;
                end else if (i_data == cont_mode_msg && prog_ready) begin
                    gral_next_state = CNT_EXEC;
                end else if (i_data == step_mode_msg && prog_ready) begin
                    gral_next_state = ST_IDLE;
                end
            end
        end

        LO_IDLE: begin
            if (i_data_ready) begin
                gral_next_state = LO_ASSIGN;
            end
        end

        LO_ASSIGN: begin
            gral_next_state = LO_INSTR_LOADED;
        end

        LO_INSTR_LOADED: begin
            if (last_instr_received) begin
                o_reset <= 1'b1; // pq estamos volviendo a idle
                gral_next_state = GRAL_IDLE;
            end else begin
                gral_next_state = LO_IDLE;
            end
        end

        CNT_EXEC: begin
            if (i_program_end) begin
                o_stall <= 1'b1;
                if (last_intr_count == 3) begin
                    o_halt <= 1'b1; // tiene que ser aca para que el pipeline no siga propagando instrucciones en el proximo ciclo de clock
                    o_stall <= 1'b0;
                    gral_next_state = SEND_INFO_TO_PC;
                end
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
                o_reset <= 1'b1;
                gral_next_state = GRAL_IDLE;
            end
        end

        ST_STAGE_EXECUTED: begin
            gral_next_state = SEND_INFO_TO_PC;
        end

        SEND_INFO_TO_PC: begin
            if(~step_mode) begin // termino la ejecucion en modo continuo
                o_reset = 1'b1; // para que en el proximo ciclo de clock se resetee el pipeline
                last_intr_count <= 2'b00;
                gral_next_state = GRAL_IDLE;
            end else begin
                if(i_program_end) begin
                    o_stall <= 1'b1;
                end
                gral_next_state = ST_IDLE; // simplemente nos vamos a ST_IDLE, que el final de la ejecucion se interprete a mano y vayamos a GRAL_IDLE con el cancel_step_msg
            end
        end
    endcase
end
endmodule
