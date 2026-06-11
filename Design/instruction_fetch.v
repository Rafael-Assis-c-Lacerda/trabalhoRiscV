// MODULO: Instruction Fetch (IF) - Estagio 1
// DESCRICAO: Busca a proxima instrucao na memoria e atualiza o Program Counter.

module instruction_fetch (
    input wire clk,                 // Sinal de relogio (sincronizacao)
    input wire rst,                 // Sinal de reset assincrono (zera o PC)
    input wire pc_src,              // Sinal de controle do MUX (0 = PC+4, 1 = Salto)
    input wire [31:0] pc_target,    // Endereco de destino calculado (Branch/Jump)
    output reg [31:0] pc,           // Endereco atual do Program Counter
    output wire [31:0] pc_plus_4    // Endereco da proxima instrucao sequencial
);

    // Fio interno para conectar a saida do Multiplexador a entrada do PC
    wire [31:0] next_pc;            

    // LOGICA COMBINACIONAL (Roteamento e Somador)
    
    // Somador dedicado do PC: Calcula o endereco da proxima instrucao (+4 bytes)
    assign pc_plus_4 = pc + 32'd4;

    // Multiplexador do PC: Decide o fluxo do programa baseado no sinal pc_src
    // Se pc_src == 1, o proximo endereco sera o alvo do salto (pc_target)
    // Se pc_src == 0, o programa segue sequencialmente (pc_plus_4)
    assign next_pc = (pc_src) ? pc_target : pc_plus_4;

    // LOGICA SEQUENCIAL (Flip-Flop do Program Counter)
    
    // O PC e um registrador sincrono. Ele so atualiza seu valor na borda 
    // de subida do relogio (posedge clk) ou quando acionado o reset.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'h0000_0000;    // Reset: Forca o PC a apontar para o endereco 0
        end else begin
            pc <= next_pc;          // Clock: Carrega o proximo endereco selecionado pelo MUX
        end
    end

endmodule