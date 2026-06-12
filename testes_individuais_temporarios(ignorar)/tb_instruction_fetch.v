`timescale 1ns / 1ps

// TESTBENCH: Valida o comportamento do estagio Instruction Fetch (IF)

module instruction_fetch_tb;

    // Declaracao de Sinais
    // 'reg' para os sinais que vamos manipular (entradas do modulo)
    reg clk;
    reg rst;
    reg pc_src;
    reg [31:0] pc_target;

    // 'wire' para observar as saidas do modulo
    wire [31:0] pc;
    wire [31:0] pc_plus_4;

    // Instanciacao do Modulo Principal (Unit Under Test - UUT)
    // Conectamos os fios do testbench aos pinos físicos do modulo IF
    instruction_fetch uut (
        .clk(clk),
        .rst(rst),
        .pc_src(pc_src),
        .pc_target(pc_target),
        .pc(pc),
        .pc_plus_4(pc_plus_4)
    );

    // Gerador de Clock
    // Inverte o sinal a cada 5 unidades de tempo (Periodo = 10ns, Freq = 100MHz)
    always #5 clk = ~clk;

    // Configuracao do Visualizador de Ondas (Obrigatorio no EDA Playground)
    initial begin
        $dumpfile("dump.vcd");              // Arquivo que armazenara as formas de onda
        $dumpvars(1, instruction_fetch_tb); // Registra as variaveis deste modulo
    end

    // Vetores de Teste (Estimulos)
    initial begin
        // ESTADO INICIAL
        clk = 0;
        rst = 1;                            // Mantem o reset acionado no inicio
        pc_src = 0;
        pc_target = 32'h0000_0000;

        // Aguarda 15ns e desliga o reset
        #15 rst = 0;
        
        // CENARIO 1: EXECUCAO SEQUENCIAL
        // O PC deve contar de 4 em 4 (0x0, 0x4, 0x8, 0xC...) a cada clock
        
        // CENARIO 2: SALTO INCONDICIONAL (JUMP)
        // Simula a decodificacao de uma instrucao JAL para o endereco 0x50
        #20 pc_target = 32'h0000_0050;      // Define o endereco alvo
        pc_src = 1;                         // Aciona a chave do MUX para o salto
        
        // CENARIO 3: RETORNO AO FLUXO SEQUENCIAL
        // Retorna o MUX para zero e verifica se o PC continua de 4 em 4 a partir do 0x50
        #10 pc_src = 0;
        
        // CENARIO 4: SALTO CONDICIONAL (BRANCH)
        // Simula um desvio tomado para o endereco 0x200
        #20 pc_target = 32'h0000_0200;
        pc_src = 1;
        
        #10 pc_src = 0;                     // Retorna ao fluxo normal
        
        // Aguarda mais 20ns e finaliza a simulacao graciosamente
        #20 $finish;
    end

endmodule