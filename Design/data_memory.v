// MODULO: Memory Access (MEM) - Estagio 4
// DESCRICAO: Memoria de Dados RAM para instrucoes de Load (LW) e Store (SW).

module data_memory (
    input wire clk,
    input wire mem_write,           // Sinal de controle: 1 = Grava na memoria (SW)
    input wire mem_read,            // Sinal de controle: 1 = Le da memoria (LW)
    input wire [31:0] address,      // Endereco de memoria calculado pela ULA
    input wire [31:0] write_data,   // Dado vindo do Registrador 2 para ser gravado
    
    output wire [31:0] read_data    // Dado lido da memoria
);

    // Criando um bloco de memoria SRAM dinamica (Ex: 256 posicoes de 32 bits = 1KB)
    reg [31:0] ram [0:255];
    
    // O RISC-V usa enderecamento por byte, mas nossa RAM e por palavras (32 bits).
    // Ignorar os 2 ultimos bits (address[31:2]) divide o endereco por 4 automaticamente.
    wire [29:0] word_addr = address[31:2];

    // LOGICA COMBINACIONAL (Leitura)
    // A leitura e instantanea se o sinal mem_read estiver ativo.
    assign read_data = (mem_read) ? ram[word_addr] : 32'd0;

    // LOGICA SEQUENCIAL (Escrita controlada pelo Clock)
    always @(posedge clk) begin
        if (mem_write) begin
            ram[word_addr] <= write_data;
        end
    end

endmodule