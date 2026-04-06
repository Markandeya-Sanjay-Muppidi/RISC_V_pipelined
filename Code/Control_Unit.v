`timescale 1ns / 1ps

module Control_Unit(Instruction,RegWrite,ALUSrc,ALUOp,MemtoReg,MemRead,MemWrite,Branch_En,Jump,
//JALR,
Imm_signal);
    input [31:0] Instruction;
    output reg RegWrite;
    output reg [1:0] ALUSrc;
    output reg [1:0] ALUOp;
    output reg [1:0] MemtoReg;
    output reg MemRead;
    output reg MemWrite;
    output reg Jump;
//    output reg JALR;        // NEW: separate signal for JALR
    output reg Imm_signal;
    output reg Branch_En;
//    output reg stall ;

    reg [6:0] opcode;
    always @(*) begin
        opcode = Instruction[6:0];
    end

    always @(*) begin
        case(opcode)
            7'b0110011 : begin          // R-Type
                RegWrite  = 1'b1;
                ALUSrc    = 2'b00;
                ALUOp     = 2'b10;
                MemtoReg  = 2'b00;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                Branch_En = 1'b0;
                Jump      = 1'b0;
//                JALR      = 1'b0;
                Imm_signal= 1'b0;
            end
            7'b0010011 : begin          // I-Type (addi, etc.)
                RegWrite  = 1'b1;
                ALUSrc    = 2'b01;
                ALUOp     = 2'b11;
                MemtoReg  = 2'b00;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                Branch_En = 1'b0;
                Jump      = 1'b0;
//                JALR      = 1'b0;
                Imm_signal= 1'b1;
            end
            7'b0000011 : begin          // Load
                RegWrite  = 1'b1;
                ALUSrc    = 2'b01;
                ALUOp     = 2'b00;
                MemtoReg  = 2'b01;
                MemRead   = 1'b1;
                MemWrite  = 1'b0;
                Branch_En = 1'b0;
                Jump      = 1'b0;
 //               JALR      = 1'b0;
                Imm_signal= 1'b1;
            end
            7'b1101111 : begin          // JAL
                RegWrite  = 1'b1;
                ALUSrc    = 2'b01;
                ALUOp     = 2'b00;
                MemtoReg  = 2'b10;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                Branch_En = 1'b0;
                Jump      = 1'b1;       // JAL uses Add_J (PC + imm)
 //               JALR      = 1'b0;
                Imm_signal= 1'b0;
            end
            7'b1100111 : begin          // JALR
                RegWrite  = 1'b1;
                ALUSrc    = 2'b01;
                ALUOp     = 2'b00;
                MemtoReg  = 2'b10;      // write PC+4 to rd
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                Branch_En = 1'b0;
                Jump      = 1'b0;       // NOT JAL - don't use Add_J
  //              JALR      = 1'b1;       // use Add_JALR (rs1 + imm)
                Imm_signal= 1'b1;
            end
            7'b0100011 : begin          // Store
                RegWrite  = 1'b0;
                ALUSrc    = 2'b01;
                ALUOp     = 2'b00;
                MemtoReg  = 2'b01;
                MemRead   = 1'b0;
                MemWrite  = 1'b1;
                Branch_En = 1'b0;
                Jump      = 1'b0;
//                JALR      = 1'b0;
                Imm_signal= 1'b1;
                
            end
            7'b1100011 : begin          // B-Type (branch)
                RegWrite  = 1'b0;
//                ALUSrc    = 2'b00;
                ALUSrc    = 2'b01; // Made it 1 so that 2nd input for address calculation is immediate.
                ALUOp     = 2'b01;
                MemtoReg  = 2'b00;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                Branch_En = 1'b1;
                Jump      = 1'b0;
 //               JALR      = 1'b0;
                Imm_signal= 1'b1;
            end
            7'b0110111 : begin          // LUI
                RegWrite  = 1'b1;
                ALUSrc    = 2'b10;
                ALUOp     = 2'b00;
                MemtoReg  = 2'b00;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                Branch_En = 1'b0;
                Jump      = 1'b0;
//                JALR      = 1'b0;
                Imm_signal= 1'b1;
            end
            7'b0010111 : begin          // AUIPC
                RegWrite  = 1'b1;
                ALUSrc    = 2'b11;
//                ALUSrc    = 2'b10;
                ALUOp     = 2'b00;
                MemtoReg  = 2'b00;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                Branch_En = 1'b0;
                Jump      = 1'b0;
//                JALR      = 1'b0;
                Imm_signal= 1'b1;
            end
            default : begin
                RegWrite  = 1'b0;
                ALUSrc    = 2'b00;
                ALUOp     = 2'b00;
                MemtoReg  = 2'b00;
                MemRead   = 1'b0;
                MemWrite  = 1'b0;
                Branch_En = 1'b0;
                Jump      = 1'b0;
//                JALR      = 1'b0;
                Imm_signal= 1'b0;
            end
        endcase
    end
endmodule