`include "instruction_fetch.v"
`include "instruction_decode.v"
`include "execute.v"
`include "data_memory.v"
`include "control_unit.v"

module top_processor (
    input wire clk,
    input wire rst
);

    wire [31:0] pc_atual, pc_mais_4;
    wire branch, jump, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire [1:0] alu_op;
    wire [31:0] instruction;
    wire [31:0] read_data1, read_data2, imm_ext;
    wire [31:0] alu_result;
    wire branch_taken; // Substituiu a flag zero
    wire [31:0] read_data_mem;
    wire [31:0] write_back_data;
    
    wire pc_src; 

    // ========================================================================
    // NOVO: LOGICA DE ENDERECAMENTO E SALTOS
    // ========================================================================
    assign pc_src = jump | (branch & branch_taken);
    
    // Calcula PC + Imediato (Usado por Branches e JAL)
    wire [31:0] target_soma_pc = pc_atual + imm_ext;
    
    // MUX que decide para onde pular: Se for JALR usa a ULA, senao usa PC+Imm
    wire [31:0] endereco_alvo;
    assign endereco_alvo = (instruction[6:0] == 7'b1100111) ? alu_result : target_soma_pc;

    // ESTAGIO 1: IF
    instruction_fetch estagio_if (
        .clk(clk), .rst(rst),
        .pc_src(pc_src),
        .pc_target(endereco_alvo), // Conectado no novo MUX de alvo
        .pc(pc_atual),
        .pc_plus_4(pc_mais_4)
    );

    reg [31:0] rom [0:255];
    assign instruction = rom[pc_atual[31:2]]; 
    
    // UNIDADE DE CONTROLE
    control_unit controle (
        .opcode(instruction[6:0]),
        .branch(branch), .jump(jump), .mem_read(mem_read), .mem_to_reg(mem_to_reg),
        .alu_op(alu_op), .mem_write(mem_write), .alu_src(alu_src), .reg_write(reg_write)
    );

    // ESTAGIO 2: ID
    instruction_decode estagio_id (
        .clk(clk), .rst(rst), .reg_write(reg_write),
        .instruction(instruction),
        .write_data(write_back_data), 
        .rd_wb(instruction[11:7]),    
        .read_data1(read_data1), .read_data2(read_data2), .imm_ext(imm_ext)
    );

    // ESTAGIO 3: EX
    execute estagio_ex (
        .read_data1(read_data1), .read_data2(read_data2), .imm_ext(imm_ext),
        .alu_src(alu_src), .alu_op(alu_op),
        .opcode(instruction[6:0]), .funct3(instruction[14:12]), .funct7(instruction[31:25]),
        .alu_result(alu_result),
        .branch_taken(branch_taken) // Conectado na nova porta
    );

    // ESTAGIO 4: MEM
    data_memory estagio_mem (
        .clk(clk), .mem_write(mem_write), .mem_read(mem_read),
        .address(alu_result), .write_data(read_data2), .read_data(read_data_mem)
    );

    // ESTAGIO 5: WB
    assign write_back_data = (jump) ? pc_mais_4 :                  
                             (mem_to_reg) ? read_data_mem :        
                             alu_result;                           

endmodule