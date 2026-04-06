`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2026 22:22:46
// Design Name: 
// Module Name: FU_mux1
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


module FU_mux1(
input [31:0]      ip_Forward_reg1,
input [31:0]      ip_ALU_op,
input [4:0]       ip_ID_EX_Rd, ip_IF_ID_Rs1,
output reg [31:0] op_Forward_Rs1
    );
    
always @(*)
begin
    if (ip_ID_EX_Rd == ip_IF_ID_Rs1) begin
        op_Forward_Rs1 <= ip_ALU_op;
    end
    else op_Forward_Rs1 <= ip_Forward_reg1;
end
endmodule


module FU_mux2(
input [31:0]      ip_Forward_reg2,
input [31:0]      ip_ALU_op,
input [4:0]       ip_ID_EX_Rd, ip_IF_ID_Rs2,
output reg [31:0] op_Forward_Rs2
    );
    
always @(*)
begin
    if (ip_ID_EX_Rd == ip_IF_ID_Rs2) begin
        op_Forward_Rs2 <= ip_ALU_op;
    end
    else op_Forward_Rs2 <= ip_Forward_reg2;
end
endmodule
