`timescale 1ns / 1ps

module tb_top_processor;
    reg clk;
    reg rst;

    // Instancia a Placa-Mãe que está no design.sv
    top_processor uut (
        .clk(clk),
        .rst(rst)
    );

    // Gerador de Clock (10ns por ciclo)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top_processor); // Grava as ondas de todos os submódulos
    end

    initial begin
        // Carrega o arquivo hexadecimal direto na memória ROM que está na Placa-Mãe
        $readmemh("program.hex", uut.rom);

        clk = 0;
        rst = 1;      // Ativa o reset
        #15 rst = 0;  // Solta o reset para o PC começar a contar de 0, 4, 8...

        #1000;        // Tempo para o programa rodar inteiro
        $finish;
    end
endmodule