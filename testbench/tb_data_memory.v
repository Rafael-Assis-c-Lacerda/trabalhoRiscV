`timescale 1ns / 1ps

// TESTBENCH: Valida a Memoria de Dados (Estagio MEM)

module data_memory_tb;

    reg clk;
    reg mem_write;
    reg mem_read;
    reg [31:0] address;
    reg [31:0] write_data;
    
    wire [31:0] read_data;

    data_memory uut (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, data_memory_tb);
    end

    initial begin
        // INICIALIZACAO
        clk = 0; 
        mem_write = 0; 
        mem_read = 0; 
        address = 0; 
        write_data = 0;
        #15;

        // TESTE 1: STORE WORD (SW)
        // Simula a CPU gravando no endereco 40
        address = 32'd40;
        write_data = 32'hDEAD_BEEF;
        mem_write = 1;
        #10 mem_write = 0;

        // TESTE 2: LOAD WORD (LW)
        // Simula a CPU pedindo a leitura do mesmo endereco 40
        #10;
        mem_read = 1;
        #10 mem_read = 0;
        
        // TESTE 3: LEITURA EM ENDERECO VAZIO
        // Tenta ler o endereco 80 (nunca foi escrito, deve retornar x (desconhecido) ou 0)
        #10;
        address = 32'd80;
        mem_read = 1;
        #10 mem_read = 0;

        #20 $finish;
    end

endmodule