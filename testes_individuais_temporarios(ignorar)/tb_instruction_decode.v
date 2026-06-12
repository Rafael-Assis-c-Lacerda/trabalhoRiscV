`timescale 1ns / 1ps

// TESTBENCH: Valida o Estagio ID (Banco de Registradores + Imm-Gen)
module instruction_decode_tb;

    reg clk;
    reg rst;
    reg reg_write;
    reg [31:0] instruction;
    reg [31:0] write_data;
    reg [4:0] rd_wb;

    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] imm_ext;

    instruction_decode uut (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .instruction(instruction),
        .write_data(write_data),
        .rd_wb(rd_wb),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .imm_ext(imm_ext)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, instruction_decode_tb);
    end

    initial begin
        clk = 0;
        rst = 1;
        reg_write = 0;
        instruction = 0;
        write_data = 0;
        rd_wb = 0;
        
        #15 rst = 0;
        
        // TESTE 1: Gravacao no Banco de Registradores 
        #10;
        // Simulando o Estagio WB enviando o valor 0xAA para o registrador x2
        rd_wb = 5'd2;
        write_data = 32'h0000_00AA;
        reg_write = 1;
        
        #10 reg_write = 0;

        // TESTE 2: Decodificacao de instrucao I-Type (ADDI x3, x2, -10) 
        // Opcode (ADDI): 0010011 | rd: 00011 (3) | funct3: 000 | rs1: 00010 (2) | imm: 111111110110 (-10)
        #10;
        instruction = 32'b111111110110_00010_000_00011_0010011;
        
        // TESTE 3: Decodificacao de instrucao S-Type (SW x3, 16(x2)) 
        // Opcode (SW): 0100011 | imm[11:5]: 0000000 | rs2: 00011 | rs1: 00010 | funct3: 010 | imm[4:0]: 10000
        #20;
        instruction = 32'b0000000_00011_00010_010_10000_0100011;
        
        #20 $finish;
    end

endmodule