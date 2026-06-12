`timescale 1ns / 1ps

// TESTBENCH: Valida a Matematica da ULA e o MUX do Estagio EX

module execute_tb;

    reg [31:0] read_data1;
    reg [31:0] read_data2;
    reg [31:0] imm_ext;
    reg alu_src;
    reg [1:0] alu_op;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    wire [31:0] alu_result;
    wire zero;

    execute uut (
        .read_data1(read_data1),
        .read_data2(read_data2),
        .imm_ext(imm_ext),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_result(alu_result),
        .zero(zero)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, execute_tb);
    end

    initial begin
        // INICIALIZACAO
        read_data1 = 0; read_data2 = 0; imm_ext = 0;
        alu_src = 0; alu_op = 2'b00;
        opcode = 0; funct3 = 0; funct7 = 0;
        #10;
        
        // TESTE 1: SOMA COM REGISTRADOR (ADD R-Type)
        // Fazendo: 15 + 25 = 40 (0x28 em Hexadecimal)
        read_data1 = 32'd15;
        read_data2 = 32'd25;
        alu_src    = 0;          // Usa o Registrador 2
        alu_op     = 2'b10;      // Operacao R-Type
        opcode     = 7'b0110011; // Opcode padrao R-Type
        funct3     = 3'b000;
        funct7     = 7'b0000000;
        #20;

        // TESTE 2: SUBTRACAO E FLAG ZERO (SUB R-Type)
        // Fazendo: 50 - 50 = 0 (Flag zero DEVE ir para 1)
        read_data1 = 32'd50;
        read_data2 = 32'd50;
        alu_src    = 0;
        alu_op     = 2'b10;
        opcode     = 7'b0110011;
        funct3     = 3'b000;
        funct7     = 7'b0100000; // Bit 30 = 1, transforma o ADD em SUB
        #20;

        // TESTE 3: AND COM IMEDIATO (ANDI I-Type)
        // Fazendo: 0x0000_FFFF AND 0x0000_00F0 = 0x0000_00F0
        read_data1 = 32'h0000_FFFF;
        imm_ext    = 32'h0000_00F0;
        alu_src    = 1;          // MUX chaveia para o Imediato
        alu_op     = 2'b10;
        opcode     = 7'b0010011; // Opcode I-Type
        funct3     = 3'b111;     // funct3 do AND
        funct7     = 7'b0000000;
        #20;

        $finish;
    end

endmodule