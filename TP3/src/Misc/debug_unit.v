module debug_unit #(
    parameter DATA_MEM_DATA_WIDTH = 8, // 1 byte por posicion de memoria
    parameter DATA_MEM_ADDR_WIDTH = 8, // Ancho de la direccion de memoria de datos
    parameter INST_MEM_ADDR_WIDTH = 9, // Ancho de la direccion de memoria de instrucciones
    parameter INST_MEM_DATA_WIDTH = 8 // 1 byte por posicion de memoria
)
(

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

    input wire [31:0] i_register_content,
    input wire [(DATA_MEM_DATA_WIDTH*4)-1:0] i_mem_data_content,
    
    // comunicacion con el pipeline
    output reg o_halt,
    output reg o_reset, // para resetear el pipeline (en realidad es para resetear el pc) cuando se vuelve a IDLE
    output wire o_stall,

    output reg o_write_instruction_flag,
    output reg [(INST_MEM_DATA_WIDTH*4)-1:0] o_instruction_to_write,
    output reg [INST_MEM_ADDR_WIDTH-1:0] o_address_to_write_inst,

    output reg [4:0] o_reg_addr_to_read,

    output reg [DATA_MEM_ADDR_WIDTH-1:0] o_addr_to_read_mem_data,

    output reg [31:0] o_data_to_fifo,
    output reg o_write_en_fifo
);

// Wires para los latches
wire [31:0] IF_ID_latch1;
wire [31:0] IF_ID_latch2;
wire [31:0] ID_EX_latch1;
wire [31:0] ID_EX_latch2;
wire [31:0] ID_EX_latch3;
wire [31:0] ID_EX_latch4;
wire [31:0] EX_MEM_latch1_ID_EX_latch5;
wire [31:0] EX_MEM_latch2;
wire [31:0] MEM_WB_latch1_EX_MEM_latch3;
wire [31:0] MEM_WB_latch2;
wire [31:0] MEM_WB_latch3;

// Estado3
localparam [3:0] GRAL_IDLE              = 4'b0000; // 0
localparam [3:0] LO_IDLE                = 4'b0001; // 1
localparam [3:0] LO_ASSIGN              = 4'b0010; // 2
localparam [3:0] LO_INSTR_LOADED        = 4'b0011; // 3
localparam [3:0] CNT_EXEC               = 4'b0100; // 4
localparam [3:0] SEND_REGISTERS         = 4'b0101; // 5
localparam [3:0] SEND_SINGLE_REGISTER   = 4'b0110; // 6
localparam [3:0] SEND_LATCHES           = 4'b0111; // 7
localparam [3:0] SEND_MEM_DATA          = 4'b1000; // 8
localparam [3:0] SEND_ACTUAL_MEM_DATA   = 4'b1001; // 9
localparam [3:0] SEND_MEM_DATA_ADDR     = 4'b1010; // 10
localparam [3:0] SEND_END_DATA          = 4'b1011; // 11
localparam [3:0] ST_IDLE                = 4'b1100; // 12
localparam [3:0] ST_ASSIGN              = 4'b1101; // 13
localparam [3:0] ST_STAGE_EXECUTED      = 4'b1110; // 14

// Manejo de estados
reg [3:0] gral_state, gral_next_state;

// para multidrive
reg next_reset;
reg aux_stall;

// fixed message - GRAL
localparam [31:0] load_mode_msg = "\0lom";
localparam [31:0] cont_mode_msg = "\0com";
localparam [31:0] step_mode_msg = "\0stm";

// fixed message - LO
localparam [31:0] end_instr = 32'hffffffff;

// fixed message - ST
localparam [31:0] cancel_step_msg = "clst";
localparam [31:0] next_step_msg = "nxst";

// fixed message - END data
localparam [31:0] end_data = "endd";

// Flags de control
reg prog_ready;
reg step_mode;
reg canceled_step;
reg [1:0] last_intr_count;
reg last_instr_received;

reg [5:0] registers_sent; // 32 registers
reg [11:0] mem_data_sent; // 32 data
reg [3:0] latches_sent; // 13 32-bit data

reg [31:0] latches_to_send[10:0];

// Manejo de estados - GRAL
always @(posedge i_clk) begin
    if (i_reset) begin
        gral_state <= GRAL_IDLE;
        o_halt <= 1'b1;
        prog_ready <= 0;
        step_mode <= 0;
        canceled_step <= 0;
        last_intr_count <= 2'b00;
        o_write_instruction_flag <= 1'b0;
        o_instruction_to_write <= 32'h00000000;
        o_address_to_write_inst <= 32'h00000000;
        last_instr_received <= 0;
        registers_sent <= 0;
        mem_data_sent <= 0;
        latches_sent <= 0;
        o_write_en_fifo <= 1'b0;
        o_reset <= 1'b0;
    end else begin
        gral_state <= gral_next_state;
        o_reset <= next_reset;

        case (gral_next_state)
            GRAL_IDLE: begin
                o_halt <= 1'b1;
                o_write_en_fifo <= 1'b0;
                last_instr_received <= 0;   // la reiniciamos por si venimos de LO_INTR_LOADED
                canceled_step <= 0;         // la reiniciamos por si venimos de ST_ASSIGN
                step_mode <= 0;             // la reiniciamos por si venimos de ST_ASSIGN
                registers_sent <= 0;        // la reiniciamos por si venimos de SEND_REGISTERS
                mem_data_sent <= 0;         // la reiniciamos por si venimos de SEND_MEM_DATA
                latches_sent <= 0;          // la reiniciamos por si venimos de SEND_LATCHES
                last_intr_count <= 2'b00;   // la reiniciamos por si venimos de SEND_END_DATA
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

            SEND_REGISTERS: begin
                o_write_en_fifo <= 1'b0;
                o_halt <= 1'b1;
                if(registers_sent <= 32) begin
                    o_reg_addr_to_read = registers_sent;
                    registers_sent = registers_sent + 1;
                end
            end

            SEND_SINGLE_REGISTER: begin
                o_write_en_fifo <= 1'b1;
                o_data_to_fifo = i_register_content;
            end

            SEND_LATCHES: begin
                o_write_en_fifo <= 1'b1;
                if(latches_sent < 11) begin
                    o_data_to_fifo = latches_to_send[latches_sent];
                    latches_sent = latches_sent + 1;
                end
            end

            SEND_MEM_DATA: begin
                o_write_en_fifo <= 1'b0;
                if(mem_data_sent <= ((2**DATA_MEM_ADDR_WIDTH)/4)) begin
                    o_addr_to_read_mem_data = mem_data_sent * 4;
                    mem_data_sent = mem_data_sent + 1;
                end
            end

            SEND_ACTUAL_MEM_DATA: begin
                o_write_en_fifo = 1'b1;
                o_data_to_fifo = i_mem_data_content;
            end

            SEND_MEM_DATA_ADDR: begin
                o_write_en_fifo <= 1'b1;
                o_data_to_fifo = o_addr_to_read_mem_data;
            end

            SEND_END_DATA: begin
                o_write_en_fifo <= 1'b1;
                o_data_to_fifo = end_data;
            end

            ST_IDLE: begin
                o_write_en_fifo <= 1'b0;
                step_mode <= 1;
                registers_sent <= 0;        // la reiniciamos porque venimos de ejecutar un paso
                mem_data_sent <= 0;         // la reiniciamos porque venimos de ejecutar un paso
                latches_sent <= 0;          // la reiniciamos porque venimos de ejecutar un paso
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
    next_reset = o_reset;
    if (i_program_end) begin
        aux_stall = 1'b1;
    end else begin
        aux_stall = 1'b0;
    end
    case (gral_state)
        GRAL_IDLE: begin
            if (i_data_ready) begin
                if (i_data == load_mode_msg) begin
                    next_reset = 1'b0;
                    gral_next_state = LO_IDLE;
                end else if (i_data == cont_mode_msg && prog_ready) begin
                    next_reset = 1'b0;
                    gral_next_state = CNT_EXEC;
                end else if (i_data == step_mode_msg && prog_ready) begin
                    next_reset = 1'b0;
                    gral_next_state = ST_IDLE;
                end
            end
            aux_stall = 1'b0;
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
                next_reset = 1'b1; // pq estamos volviendo a idle
                gral_next_state = GRAL_IDLE;
            end else begin
                gral_next_state = LO_IDLE;
            end
        end

        CNT_EXEC: begin
            if (i_program_end) begin
                //aux_stall = 1'b1;
                if (last_intr_count == 3) begin
                    gral_next_state = SEND_REGISTERS;
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
                next_reset = 1'b1;
                gral_next_state = GRAL_IDLE;
            end
        end

        ST_STAGE_EXECUTED: begin
            gral_next_state = SEND_REGISTERS;
        end

        SEND_REGISTERS: begin
            //aux_stall = 1'b0; // para cuando venimos del CNT_EXEC
            if (registers_sent <= 32) begin
                gral_next_state = SEND_SINGLE_REGISTER;
            end else begin
                gral_next_state = SEND_LATCHES;
            end
        end

        SEND_SINGLE_REGISTER: begin
            gral_next_state = SEND_REGISTERS;
        end

        SEND_LATCHES: begin
            if (latches_sent >= 11) begin
                gral_next_state = SEND_MEM_DATA;
            end
        end

        SEND_MEM_DATA: begin
            if(mem_data_sent <= ((2**DATA_MEM_ADDR_WIDTH)/4)) begin
                if (i_mem_data_content != 32'h00000000 && ((|i_mem_data_content) || (~&i_mem_data_content))) begin //detecta que el dato no es 0 ni indefinido
                    gral_next_state = SEND_ACTUAL_MEM_DATA;
                end
            end else begin
                gral_next_state = SEND_END_DATA;
            end
        end

        SEND_ACTUAL_MEM_DATA: begin
            gral_next_state = SEND_MEM_DATA_ADDR;
        end

        SEND_MEM_DATA_ADDR: begin
            gral_next_state = SEND_MEM_DATA;
        end

        SEND_END_DATA: begin
            if(~step_mode) begin // termino la ejecucion en modo continuo
                next_reset = 1'b1; // para que en el proximo ciclo de clock se resetee el pipeline
                gral_next_state = GRAL_IDLE;
            end else begin
                // if(i_program_end) begin
                //     aux_stall = 1'b1;
                // end
                gral_next_state = ST_IDLE; // simplemente nos vamos a ST_IDLE, que el final de la ejecucion se interprete a mano y vayamos a GRAL_IDLE con el cancel_step_msg
            end
        end
    endcase
end

always @(*) begin
    latches_to_send[0] <= i_IF_ID_latch[31:0];
    latches_to_send[1] <= i_IF_ID_latch[63:32];
    latches_to_send[2] <= i_ID_EX_latch[31:0];
    latches_to_send[3] <= i_ID_EX_latch[63:32];
    latches_to_send[4] <= i_ID_EX_latch[95:64];
    latches_to_send[5] <= i_ID_EX_latch[127:96];
    latches_to_send[6] <= {i_EX_MEM_latch[20:0], i_ID_EX_latch[138:128]};
    latches_to_send[7] <= i_EX_MEM_latch[52:21];
    latches_to_send[8] <= {i_MEM_WB_latch[8:0], i_EX_MEM_latch[75:53]};
    latches_to_send[9] <= i_MEM_WB_latch[40:9];
    latches_to_send[10] <= i_MEM_WB_latch[70:41]; // two msb are ignored
end

assign o_stall = i_reset ? 1'b0 : aux_stall;

endmodule
