// MODULO: Execute (EX) - Estagio 3
module execute (
    input wire [31:0] read_data1,
    input wire [31:0] read_data2,
    input wire [31:0] imm_ext,
    input wire alu_src,
    input wire [1:0] alu_op,
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    
    output reg [31:0] alu_result,
    output reg branch_taken       // NOVO: Substitui a flag "zero"
);

    wire [31:0] alu_in_b;
    assign alu_in_b = (alu_src) ? imm_ext : read_data2;

    reg [3:0] alu_ctrl;

    always @(*) begin
        if (alu_op == 2'b00) begin
            alu_ctrl = 4'b0010;
        end else if (alu_op == 2'b01) begin
            alu_ctrl = 4'b0110;
        end else if (alu_op == 2'b11) begin
            alu_ctrl = 4'b1111;     // NOVO: Codigo especial para o LUI
        end else begin
            case (funct3)
                3'b000: begin
                    if ((opcode == 7'b0110011) && (funct7[5] == 1'b1)) alu_ctrl = 4'b0110;
                    else alu_ctrl = 4'b0010;
                end
                3'b111: alu_ctrl = 4'b0000;
                3'b110: alu_ctrl = 4'b0001;
                3'b100: alu_ctrl = 4'b1001;
                3'b001: alu_ctrl = 4'b1010;
                3'b101: begin
                    if (funct7[5] == 1'b1) alu_ctrl = 4'b1100;
                    else                   alu_ctrl = 4'b1011;
                end
                3'b010: alu_ctrl = 4'b0111;
                3'b011: alu_ctrl = 4'b1000;
                default: alu_ctrl = 4'b0000;
            endcase
        end
    end

    // ULA MATEMATICA
    always @(*) begin
        case (alu_ctrl)
            4'b0000: alu_result = read_data1 & alu_in_b;
            4'b0001: alu_result = read_data1 | alu_in_b;
            4'b0010: alu_result = read_data1 + alu_in_b;
            4'b0110: alu_result = read_data1 - alu_in_b;
            4'b1001: alu_result = read_data1 ^ alu_in_b;
            4'b1010: alu_result = read_data1 << alu_in_b[4:0];
            4'b1011: alu_result = read_data1 >> alu_in_b[4:0];
            4'b1100: alu_result = $signed(read_data1) >>> alu_in_b[4:0];
            4'b0111: alu_result = ($signed(read_data1) < $signed(alu_in_b)) ? 32'd1 : 32'd0;
            4'b1000: alu_result = (read_data1 < alu_in_b) ? 32'd1 : 32'd0;
            4'b1111: alu_result = imm_ext; // NOVO: LUI passa direto
            default: alu_result = 32'd0;
        endcase
    end

    // AVALIADOR DE DESVIOS (Resolve as 6 instrucoes B-Type)
    always @(*) begin
        if (opcode == 7'b1100011) begin
            case (funct3)
                3'b000: branch_taken = (read_data1 == read_data2);                     // BEQ
                3'b001: branch_taken = (read_data1 != read_data2);                     // BNE
                3'b100: branch_taken = ($signed(read_data1) < $signed(read_data2));    // BLT
                3'b101: branch_taken = ($signed(read_data1) >= $signed(read_data2));   // BGE
                3'b110: branch_taken = (read_data1 < read_data2);                      // BLTU
                3'b111: branch_taken = (read_data1 >= read_data2);                     // BGEU
                default: branch_taken = 1'b0;
            endcase
        end else begin
            branch_taken = 1'b0;
        end
    end

endmodule