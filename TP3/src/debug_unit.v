module debug_unit(

    input wire i_clk,
    input wire i_reset,

    input wire i_data_ready,
    input wire [31:0] i_data,

)


// Estados generales
localparam [1:0] GRAL_IDLE   = 2'b00;
localparam [1:0] GRAL_CHARGE = 2'b01;
localparam [1:0] GRAL_CONT   = 2'b10;
localparam [1:0] GRAL_STEP   = 2'b11;

// Estados de carga
localparam [1:0] CH_IDLE   = 2'b00;
localparam [1:0] CH_ASSIGN = 2'b01;
localparam [1:0] CH_READY  = 2'b10;

// Estados de cont
localparam [1:0] CNT_EXEC   = 2'b00;
localparam [1:0] CNT_READY  = 2'b01;

// Estados de step
localparam [1:0] ST_IDLE   = 2'b00;
localparam [1:0] ST_ASSIGN = 2'b01;
localparam [1:0] ST_READY  = 2'b10;

// Manejo de estados
reg [1:0] gral_state, gral_next_state;
reg [1:0] ch_state, ch_next_state;
reg [1:0] cnt_state, cnt_next_state;
reg [1:0] st_state, st_next_state;

// fixed message - GRAL
localparam [31:0] charge_mode = "\0chm";
localparam [31:0] cont_mode = "\0com";
localparam [31:0] step_mode = "\0stm";

// fixed message - CH
localparam [31:0] end_instr = 32'hffffffff;

// fixed message - ST
localparam [31:0] cancel_step = "clst";

// Flags de control
reg progready;

// Manejo de estados - GRAL

// Logica de la maquina de estados - GRAL






    
endmodule