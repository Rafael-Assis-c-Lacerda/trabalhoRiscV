`timescale 1ns / 1ps

module tb_top_processor;
    reg clk;
    reg rst;

    // Instancia a Placa-Mae com todos os estagios ja conectados
    top_processor uut (
        .clk(clk),
        .rst(rst)
    );

    // Gerador de Clock (10ns por ciclo)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top_processor); // Grava a maquina inteira
    end

    initial begin
        // Carrega o arquivo hexadecimal com as 39 linhas
        $readmemh("program.hex", uut.rom);

        clk = 0;
        rst = 1;      // Ativa o reset
        #15 rst = 0;  // Solta o reset para o PC comecar a andar

        #1000;        // Tempo suficiente para rodar todo o programa
        $finish;
    end
endmodule