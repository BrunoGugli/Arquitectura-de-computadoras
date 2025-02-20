module instruction_exec_tb;

    reg i_clk;
    reg i_reset;
    reg i_halt;

    // señales de control
    reg i_ctl_EX_reg_dest_EX;
    reg i_ctl_EX_alu_src_EX;
    reg [1:0] i_ctl_EX_alu_op_EX;

    reg i_ctl_MEM_mem_read_EX;
    reg i_ctl_MEM_mem_write_EX;
    reg i_ctl_MEM_unsigned_EX;
    reg [1:0] i_ctl_MEM_data_width_EX;

    reg i_ctl_WB_mem_to_reg_EX;
    reg i_ctl_WB_reg_write_EX;

    // lo que viene del ID
    reg [31:0] i_RA;
    reg [31:0] i_RB;
    reg [4:0] i_rs;
    reg [4:0] i_rt;
    reg [4:0] i_rd;
    reg [5:0] i_funct;
    reg [31:0] i_inmediate;
    reg [5:0] i_opcode;
    reg [4:0] i_shamt;

    // de la forward unit
    reg [1:0] i_forward_A;
    reg [1:0] i_forward_B;

    // datos de mem y write-back
    reg [31:0] i_MEM_ALU_result;
    reg [31:0] i_WB_read_data;

    // señales de control output
    wire o_ctl_MEM_mem_read_EX;
    wire o_ctl_MEM_mem_write_EX;
    wire o_ctl_MEM_unsigned_EX;
    wire [1:0] o_ctl_MEM_data_width_EX;
    wire o_ctl_WB_mem_to_reg_EX;
    wire o_ctl_WB_reg_write_EX;

    // lo que va a MEM
    wire [31:0] o_ALU_result;
    wire [31:0] o_data_to_write;
    wire [4:0] o_reg_dest;

    instruction_exec uut (

        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_halt(i_halt),
        .i_ctl_EX_reg_dest_EX(i_ctl_EX_reg_dest_EX),
        .i_ctl_EX_alu_src_EX(i_ctl_EX_alu_src_EX),
        .i_ctl_EX_alu_op_EX(i_ctl_EX_alu_op_EX),
        .i_ctl_MEM_mem_read_EX(i_ctl_MEM_mem_read_EX),
        .i_ctl_MEM_mem_write_EX(i_ctl_MEM_mem_write_EX),
        .i_ctl_MEM_unsigned_EX(i_ctl_MEM_unsigned_EX),
        .i_ctl_MEM_data_width_EX(i_ctl_MEM_data_width_EX),
        .i_ctl_WB_mem_to_reg_EX(i_ctl_WB_mem_to_reg_EX),
        .i_ctl_WB_reg_write_EX(i_ctl_WB_reg_write_EX),
        .i_RA(i_RA),
        .i_RB(i_RB),
        .i_rs(i_rs),
        .i_rt(i_rt),
        .i_rd(i_rd),
        .i_funct(i_funct),
        .i_inmediate(i_inmediate),
        .i_opcode(i_opcode),
        .i_shamt(i_shamt),
        .i_forward_A(i_forward_A),
        .i_forward_B(i_forward_B),
        .i_MEM_ALU_result(i_MEM_ALU_result),
        .i_WB_read_data(i_WB_read_data),
        .o_ctl_MEM_mem_read_EX(o_ctl_MEM_mem_read_EX),
        .o_ctl_MEM_mem_write_EX(o_ctl_MEM_mem_write_EX),
        .o_ctl_MEM_unsigned_EX(o_ctl_MEM_unsigned_EX),
        .o_ctl_MEM_data_width_EX(o_ctl_MEM_data_width_EX),
        .o_ctl_WB_mem_to_reg_EX(o_ctl_WB_mem_to_reg_EX),
        .o_ctl_WB_reg_write_EX(o_ctl_WB_reg_write_EX),
        .o_ALU_result(o_ALU_result),
        .o_data_to_write(o_data_to_write),
        .o_reg_dest(o_reg_dest)
    );

    // Generación de reloj
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk; // Período de 10 unidades de tiempo
    end

    initial begin
        // Inicialización
        @ (posedge i_clk);
        i_halt = 0;

        // Señales de control de la ALU
        i_ctl_EX_reg_dest_EX = 1; // rd es destino para el test ADD
        i_ctl_EX_alu_op_EX = 2'b10; // tipo r
        i_ctl_EX_alu_src_EX = 0; // rs y rt son fuentes

        // Señales de control de la MEM
        i_ctl_MEM_mem_read_EX = 0;
        i_ctl_MEM_mem_write_EX = 0;
        i_ctl_MEM_unsigned_EX = 0;
        i_ctl_MEM_data_width_EX = 2'b00;

        // Señales de control de la WB
        i_ctl_WB_mem_to_reg_EX = 1;
        i_ctl_WB_reg_write_EX = 1;

        // Valores de entrada a la ALU
        i_RA = 0;
        i_RB = 0;
        i_inmediate = 16'b0001100000100000;

        // Instruction
        i_rs = 5'b00001;
        i_rt = 5'b00010;
        i_rd = 5'b00011;
        i_funct = 6'b100000;
        i_opcode = 6'b000000;
        i_shamt = 5'b00000;

        // Forwarding
        i_forward_A = 2'b00;
        i_forward_B = 2'b00;
        i_MEM_ALU_result = 32'h00000000;
        i_WB_read_data = 32'h00000000;

        // TEST 1: ADD (R-Type)
        #10;
        i_RA = 32'h00000005;
        i_RB = 32'h00000003;

        // TEST 2: ADD negativo (I-Type)
        #10;
        i_RA = 32'h00000005;
        //-3
        i_RB = 32'b1111_1111_1111_1111_1111_1111_1111_1101; 

        // TEST 3: ADDU (R-Type)
        #10;
        i_RA = 32'h0000001;
        i_RB = 32'b1111_1111_1111_1111_1111_1111_1111_1001; //4294967293

        // TEST 4: Forwarding A
        #10;
        i_forward_A = 2'b10;
        i_MEM_ALU_result = 32'b1111_1111_1111_1111_1111_1111_1111_1010; //4294967294
        i_opcode = 6'b000000;
        i_funct = 6'b100010;        
        
    end





endmodule