module instruction_mem #(
    parameter DATA_WIDTH = 8, // 1 byte por posicion de memoria
    parameter MEM_ADDR_WIDTH = 8 // recordar cambiar en la debug unit
)
(
    input wire i_clk,
    input wire i_reset,
    input wire i_halt,

    // señales de control
    input wire i_ctl_MEM_mem_read_MEM,
    input wire i_ctl_MEM_mem_write_MEM,
    input wire i_ctl_MEM_unsigned_MEM,
    input wire [1:0] i_ctl_MEM_data_width_MEM,

    input wire i_ctl_WB_mem_to_reg_MEM,
    input wire i_ctl_WB_reg_write_MEM,

    // lo que viene de EX
    input wire [31:0] i_ALU_result,
    input wire [31:0] i_data_to_write,
    input wire [4:0] i_reg_dest,

    // señales de control output
    output reg o_ctl_WB_mem_to_reg_MEM,
    output reg o_ctl_WB_reg_write_MEM,

    // lo que va a WB
    output reg [31:0] o_ALU_result,
    output reg [31:0] o_data_readed_from_memory,
    output reg [4:0] o_reg_dest,

    // Debug unit
    input wire [MEM_ADDR_WIDTH-1:0] i_address_to_read_from_debug,
    output wire [(DATA_WIDTH*4)-1:0] o_mem_addr_content_to_debug
);

    localparam BYTE = 2'b00;
    localparam HALF_WORD = 2'b01;
    localparam WORD = 2'b11;

    wire [(DATA_WIDTH*4)-1:0] data_readed_from_memory;
    reg [MEM_ADDR_WIDTH-1:0] address_to_access_memory; // Este cable intermedio para manejar la direccion de acceso a memoria por si esta desalineada para su respectivo caso

    xilinx_one_port_ram_async #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(MEM_ADDR_WIDTH) // el ancho del resultado de la ALU
    ) data_memory (
        .i_clk(i_clk),
        .i_we(i_ctl_MEM_mem_write_MEM),
        .i_writing_data_width(i_ctl_MEM_data_width_MEM),
        .i_addr(address_to_access_memory),
        .i_data(i_data_to_write),
        .o_data(data_readed_from_memory)
    );
    

    // Alu result y reg dest
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_ALU_result <= 32'h0;
            o_reg_dest <= 5'b0;
        end else begin
            if(~i_halt) begin
                o_ALU_result <= i_ALU_result;
                o_reg_dest <= i_reg_dest;
            end
        end
    end

    // manejo de la direccion de acceso a memoria
    always @(*) begin
        if(~i_halt) begin
            case(i_ctl_MEM_data_width_MEM)
                BYTE: begin
                    address_to_access_memory <= i_ALU_result[MEM_ADDR_WIDTH-1:0];
                end
                HALF_WORD: begin
                    address_to_access_memory <= {i_ALU_result[MEM_ADDR_WIDTH-1:1], 1'b0}; // si es half word, se alinea la direccion a la mas cercana en caso de estar desalineada (lsb = 0)
                end
                WORD: begin
                    address_to_access_memory <= {i_ALU_result[MEM_ADDR_WIDTH-1:2], 2'b00}; // si es word, se alinea la direccion a la mas cercana en caso de estar desalineada (2 lsb = 00)
                end
                default: begin
                    address_to_access_memory <= 0; 
                end
            endcase
        end else begin
            address_to_access_memory <= i_address_to_read_from_debug[MEM_ADDR_WIDTH-1:0] & {{(MEM_ADDR_WIDTH-2){1'b1}}, 2'b00}; 
        end
    end

    // lecturas (las escrituras ya se manejan con la memoria)
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_data_readed_from_memory <= 32'h0;
        end else begin
            if(~i_halt) begin
                case(i_ctl_MEM_data_width_MEM)
                    BYTE: begin
                        if (i_ctl_MEM_mem_read_MEM) begin
                            o_data_readed_from_memory <= i_ctl_MEM_unsigned_MEM ? {{(24){1'b0}}, data_readed_from_memory[7:0]} : {{(24){data_readed_from_memory[7]}}, data_readed_from_memory[7:0]};
                        end 
                    end
                    HALF_WORD: begin
                        if (i_ctl_MEM_mem_read_MEM) begin
                            o_data_readed_from_memory <= i_ctl_MEM_unsigned_MEM ? {{(16){1'b0}}, data_readed_from_memory[15:0]} : {{(16){data_readed_from_memory[15]}}, data_readed_from_memory[15:0]};
                        end
                    end
                    WORD: begin
                        if (i_ctl_MEM_mem_read_MEM) begin
                            o_data_readed_from_memory <= data_readed_from_memory;
                        end
                    end
                endcase
            end
        end
    end

    // señales de control
    always @(posedge i_clk) begin
        if(i_reset) begin
            o_ctl_WB_mem_to_reg_MEM <= 1'b0;
            o_ctl_WB_reg_write_MEM <= 1'b0;
        end else begin
            if(~i_halt) begin
                o_ctl_WB_mem_to_reg_MEM      <= i_ctl_WB_mem_to_reg_MEM;
                o_ctl_WB_reg_write_MEM       <= i_ctl_WB_reg_write_MEM;
            end
        end
    end

    assign o_mem_addr_content_to_debug = data_readed_from_memory;

endmodule
