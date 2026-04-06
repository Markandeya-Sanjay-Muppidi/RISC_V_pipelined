`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2024 02:50:31 PM
// Design Name: 
// Module Name: ALU_Unit
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
module ALU_Unit(Read_data1, Mux_Data, ALU_Control, ALU_Result);
    //<-----------------PORT DECLARATION----------------------------->
    input  [31:0] Read_data1;      // Output of first output port of Register file.
    input  [31:0] Mux_Data;        // Output of second output port of Register file / immediate generator.
    input  [5:0]  ALU_Control;     // Output of ALU Control Unit.
    output reg [31:0] ALU_Result;  // Output of ALU unit.

    //<-------------------ALU Operations------------------------------>
    always @(*) begin
        case(ALU_Control)
            6'd1  : ALU_Result <= Read_data1 + Mux_Data;                                     // add
            6'd2  : ALU_Result <= Read_data1 - Mux_Data;                                     // sub
            6'd3  : ALU_Result <= Read_data1 & Mux_Data;                                     // and
            6'd4  : ALU_Result <= Read_data1 | Mux_Data;                                     // or
            6'd5  : ALU_Result <= Read_data1 ^ Mux_Data;                                     // xor
            6'd6  : ALU_Result <= Read_data1 << Mux_Data[4:0];                               // sll
            6'd7  : ALU_Result <= ($signed(Read_data1) < $signed(Mux_Data)) ? 32'd1 : 32'd0; // slt
            6'd8  : ALU_Result <= (Read_data1 < Mux_Data) ? 32'd1 : 32'd0;                   // sltu
            6'd9  : ALU_Result <= Read_data1 >> Mux_Data[4:0];                               // srl
            6'd10 : ALU_Result <= $signed(Read_data1) >>> Mux_Data[4:0];                     // sra
            default: ALU_Result <= 32'b0;
        endcase
    end
endmodule