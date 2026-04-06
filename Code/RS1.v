`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/25/2024 09:07:47 PM
// Design Name: 
// Module Name: U_Reg_Mux_ALU
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


module U_Reg_Mux_ALU(op_PC,ip_Data_out1,ip_EX_MEM_ALU_Result,sel_ForwardA,ip_MEM_WB_WriteBack,ip_MEM_Read,op_Data_out1);
    input [31:0] ip_Data_out1;            // Output of first Register File
    input [31:0] ip_EX_MEM_ALU_Result;    // Output of ALU from EX-MEM Stage            
    input [31:0] ip_MEM_WB_WriteBack;     // Output of WriteBack MUX from MEM-WB Stage  
    input [31:0] op_PC;                   // PC 
    input [2:0] sel_ForwardA;             // Output from Forwarding Unit  
    input [31:0] ip_MEM_Read ;
    output reg [31:0] op_Data_out1;       // Output of MUX      
    //<------------------------------------------------->  
    always @ (*) 
        begin
            case(sel_ForwardA)
                3'b000 : begin
                    op_Data_out1 <= ip_Data_out1;
                end
                3'b110 : begin
                    op_Data_out1 <= ip_EX_MEM_ALU_Result;
                end
                3'b101 : begin
                    op_Data_out1 <= ip_MEM_WB_WriteBack;
                end
                3'b010 : begin
                    op_Data_out1 <= 32'b0;
                end 
                3'b011 : begin
                    op_Data_out1 <= op_PC;
                end
                3'b111 : begin
                    op_Data_out1 <= ip_MEM_Read;
                end
                default : 
                    op_Data_out1 <= 32'b0;
            endcase

//          case (sel_ForwardA)
//            3'b000 : op_Data_out1 <= ip_Data_out1;
//            3'b001 : op_Data_out1 <= ip_Data_out1;
//            3'b010 : op_Data_out1 <= 32'b0;             // LUI: ALU-A = 0
//            3'b011 : op_Data_out1 <= op_PC;             // AUIPC: ALU-A = PC
//            3'b110 : op_Data_out1 <= ip_EX_MEM_ALU_Result;
//            3'b101 : op_Data_out1 <= ip_MEM_WB_WriteBack;
//            default: op_Data_out1 <= ip_Data_out1;
//        endcase
        end          
endmodule