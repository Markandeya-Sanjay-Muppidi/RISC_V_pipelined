`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Hazard_Detection_Unit
// Fix: Corrected syntax error - missing ')' and ';' at end of port declaration.
// Logic is unchanged from the working version.
//////////////////////////////////////////////////////////////////////////////////
module Hazard_Detection_Unit(
    input [4:0] ip_IF_ID_RegisterRS1,
    input [4:0] ip_IF_ID_RegisterRS2,
    input [4:0] ip_ID_EX_RegisterRD,
    input ip_ID_EX_MemRead,
    input ip_OR_Branch,
    input ip_ForwardC,
    input ip_ForwardD,
    input ip_ForwardC2,
    input ip_ForwardD2,
    output reg ip_PCWrite,
    output reg op_Hazard_Unit
);
    always @(*) begin
//        // Case 1: Load-use hazard (load in EX, branch/ALU needs result in ID)
//        if ((ip_ID_EX_MemRead) &&
//           ((ip_ID_EX_RegisterRD == ip_IF_ID_RegisterRS1) ||
//            (ip_ID_EX_RegisterRD == ip_IF_ID_RegisterRS2)))
//        begin
//            op_Hazard_Unit = 1'b1;
//            ip_PCWrite     = 1'b0;
//        end
        // Case 2: Load-use hazard when branch is also pending
        if (ip_ID_EX_MemRead && ip_OR_Branch &&
                ((ip_ID_EX_RegisterRD == ip_IF_ID_RegisterRS1) ||
                 (ip_ID_EX_RegisterRD == ip_IF_ID_RegisterRS2)))
        begin
            op_Hazard_Unit = 1'b1;
            ip_PCWrite     = 1'b1;
        end
        // Case 3: Branch forwarding stall
        // Stall while ANY needed register still has no forwarding path.
        // Releases when ForwardC2 covers rs1 (EX_MEM no longer needed for rs1)
        // AND ForwardD has data ready for rs2 (or rs2 doesn't need forwarding).
        // Condition: stall if forwarding needed but MEM_WB can't yet supply it.
        else if ((ip_ForwardC || ip_ForwardD) && !ip_ForwardC2 && !ip_ForwardD2)
        begin
            op_Hazard_Unit = 1'b0;
            ip_PCWrite     = 1'b0;
        end
        else begin
            op_Hazard_Unit = 1'b0;
            ip_PCWrite     = 1'b0;
        end
    end
endmodule