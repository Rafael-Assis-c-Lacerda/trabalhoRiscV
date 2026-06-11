// MODULO: Unidade de Controle Principal
module control_unit (
    input wire [6:0] opcode,
    output reg branch, jump, mem_read, mem_to_reg, mem_write, alu_src, reg_write,
    output reg [1:0] alu_op
);

    always @(*) begin
        branch = 1'b0; jump = 1'b0; mem_read = 1'b0; mem_to_reg = 1'b0;
        alu_op = 2'b00; mem_write = 1'b0; alu_src = 1'b0; reg_write = 1'b0;

        case (opcode)
            7'b0110011: begin // R-Type
                reg_write = 1'b1; alu_op = 2'b10;
            end
            7'b0010011: begin // I-Type
                alu_src = 1'b1; reg_write = 1'b1; alu_op = 2'b10;
            end
            7'b0000011: begin // LW
                alu_src = 1'b1; mem_to_reg = 1'b1; reg_write = 1'b1; mem_read = 1'b1;
            end
            7'b0100011: begin // SW
                alu_src = 1'b1; mem_write = 1'b1;
            end
            7'b1100011: begin // B-Type (Branch)
                branch = 1'b1; alu_op = 2'b01;
            end
            7'b1101111: begin // JAL
                jump = 1'b1; reg_write = 1'b1;
            end
            7'b1100111: begin // NOVO: JALR
                jump = 1'b1; alu_src = 1'b1; reg_write = 1'b1; alu_op = 2'b10;
            end
            7'b0110111: begin // LUI
                alu_src = 1'b1; reg_write = 1'b1; alu_op = 2'b11; 
            end
            default: ;
        endcase
    end
endmodule