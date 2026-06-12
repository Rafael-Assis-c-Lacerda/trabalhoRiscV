`timescale 1ns / 1ps

module control_unit_tb;

    reg [6:0] opcode;
    wire branch, jump, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire [1:0] alu_op;

    control_unit uut (
        .opcode(opcode),
        .branch(branch),
        .jump(jump),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1, control_unit_tb);
    end

    initial begin
        // TESTE 1: R-Type (ADD)
        opcode = 7'b0110011; 
        #10;
        
        // TESTE 2: Load Word (LW)
        opcode = 7'b0000011;
        #10;
        
        // TESTE 3: Branch (BEQ)
        opcode = 7'b1100011;
        #10;
        
        $finish;
    end
endmodule