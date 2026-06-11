// MODULO: Instruction Decode (ID) - Estagio 2
// DESCRICAO: Contem o Banco de Registradores e o Gerador de Imediatos (Imm-Gen).

module instruction_decode (
    input wire clk,
    input wire rst,
    input wire reg_write,           // Sinal da Unidade de Controle (1 = Grava no rd)
    input wire [31:0] instruction,  // Instrucao de 32 bits vinda do Estagio IF
    input wire [31:0] write_data,   // Dado que vem do Estagio WB para ser gravado
    input wire [4:0] rd_wb,         // Endereco de destino (rd) que vem do Estagio WB
    
    output wire [31:0] read_data1,  // Dado lido do rs1
    output wire [31:0] read_data2,  // Dado lido do rs2
    output reg [31:0] imm_ext       // Imediato estendido para 32 bits
);

    // Fatiamento da Instrucao (Decodificacao basica dos campos)
    wire [6:0] opcode = instruction[6:0];
    wire [4:0] rs1    = instruction[19:15];
    wire [4:0] rs2    = instruction[24:20];

    // 1. BANCO DE REGISTRADORES (Register File)
    reg [31:0] registers [0:31];
    integer i;

    // Leitura Combinacional (x0 sempre aterrado em 0)
    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    // Escrita Sequencial
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else begin
            // Grava apenas se permitido e NUNCA no registrador x0
            if (reg_write && (rd_wb != 5'd0)) begin
                registers[rd_wb] <= write_data;
            end
        end
    end

    // 2. GERADOR DE IMEDIATOS (Imm-Gen)
    // Logica combinacional para estender o sinal baseado no formato da instrucao
    always @(*) begin
        // Valor default para evitar inferencia de Latch (Boa pratica pedida no roteiro)
        imm_ext = 32'd0; 

        case (opcode)
            // I-Type (Ex: ADDI, SLTI, LW, JALR)
            7'b0010011, 7'b0000011, 7'b1100111: begin
                imm_ext = {{20{instruction[31]}}, instruction[31:20]};
            end
            
            // S-Type (Ex: SW)
            7'b0100011: begin
                imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            // B-Type (Ex: BEQ, BNE, BLT)
            7'b1100011: begin
                imm_ext = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            
            // U-Type (Ex: LUI)
            7'b0110111: begin
                imm_ext = {instruction[31:12], 12'd0};
            end
            
            // J-Type (Ex: JAL)
            7'b1101111: begin
                imm_ext = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            
            default: begin
                imm_ext = 32'd0; // R-Type ou instrucao invalida nao usam imediato
            end
        endcase
    end

endmodule