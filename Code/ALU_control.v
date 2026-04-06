`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2024 01:54:04 PM
// Design Name: 
// Module Name: ALU_CTRL_UNIT
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ALU_CTRL_UNIT(Instruction, ALUOp, ALUCtrl, branch_in);
    //<------------------------PORT DECLARATION-------------------->
    input  [31:0] Instruction;   // Complete Instruction as input
    input  [1:0]  ALUOp;         // ALU Opcode from Control Unit
    output reg [5:0] ALUCtrl;    // Output of ALU Control Unit
    output reg branch_in;

    reg       Inst;              // Bit 30 of Instruction
    reg [2:0] funct3;            // funct3 field of Instruction

    //<------------------------------------------------------------->
    always @(*) begin
        Inst   = Instruction[30];
        funct3 = Instruction[14:12];

        if (Instruction == 32'b0) begin
            ALUCtrl = 6'd0;
        end
        else begin
            case(ALUOp)
                //<-----------R-Type Instructions ----------------->
                2'b10 : begin
                    case(funct3)
                        3'b000: ALUCtrl <= (Inst == 1'b0) ? 6'd1  : 6'd2;  // add : sub
                        3'b111: ALUCtrl <= 6'd3;                             // and
                        3'b110: ALUCtrl <= 6'd4;                             // or
                        3'b100: ALUCtrl <= 6'd5;                             // xor
                        3'b001: ALUCtrl <= 6'd6;                             // sll
                        3'b010: ALUCtrl <= 6'd7;                             // slt
                        3'b011: ALUCtrl <= 6'd8;                             // sltu
                        3'b101: ALUCtrl <= (Inst == 1'b0) ? 6'd9  : 6'd10; // srl : sra
                        default: ALUCtrl <= 6'd0;
                    endcase
                end
                //<-----------I-Type Instructions ----------------->
                2'b11 : begin
                    case(funct3)
                        3'b000: ALUCtrl <= 6'd1;                             // addi
                        3'b111: ALUCtrl <= 6'd3;                             // andi
                        3'b110: ALUCtrl <= 6'd4;                             // ori
                        3'b100: ALUCtrl <= 6'd5;                             // xori
                        3'b001: ALUCtrl <= 6'd6;                             // slli
                        3'b010: ALUCtrl <= 6'd7;                             // slti
                        3'b011: ALUCtrl <= 6'd8;                             // sltiu
                        3'b101: ALUCtrl <= (Inst == 1'b0) ? 6'd9  : 6'd10; // srli : srai
                        default: ALUCtrl <= 6'd0;
                    endcase
                end
                //<-----------Load / Store/ U Instructions ----------->
                2'b00 : begin
                    ALUCtrl <= 6'd1; // add (address calculation)
                end
                //<-----------Branch Instructions ----------------->
                2'b01 : begin
                    ALUCtrl <= 6'd1; // add (branch target)
                end
                default: ALUCtrl <= 6'd0;
            endcase
        end
    end
endmodule