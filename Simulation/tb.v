`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2026 22:32:21
// Design Name: 
// Module Name: tb
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


module tb();
    reg clk;
    reg reset;
//    reg [31:0] Instruction;
    wire [31:0] op_WriteBack;
    //<-----------------DUT----------------------->
    Top_Module DUT(
    .clk(clk),               
    .reset(reset),             
//    .Instruction(Instruction),
    .op_WriteBack(op_WriteBack)
    );
    //<-------------Clock Generation---------------->
    always #5 clk=~clk;
    initial 
        begin
            clk=1;
            reset=1;
         #11
            reset=0;   
                                      
        #150 $finish();            
            
        end
endmodule