
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Forward_4x2_First
// Fix: Added MEM_WB forwarding path (ForwardC2) for branch RS1
//      Priority: EX_MEM > MEM_WB > Register File
//////////////////////////////////////////////////////////////////////////////////
module Forward_Unit_RS1(
    input [31:0] ip_IF_ID_RegisterRS1,     // Raw value from Register File
    input [31:0] ip_EX_MEM_ALU_Result,     // EX/MEM stage result
    input [31:0] ip_MEM_WB_RegisterRS1,    // MEM/WB stage result
    input [31:0] ip_ALU_op,                // ID/EX stage ALU result (latest)
    input [4:0]  ip_ID_EX_Rd,              // Destination register (ID/EX)
    input [4:0]  ip_IF_ID_Rs1,             // Source register (IF/ID)
    input [31:0] ip_MEM_Read,
    input [1:0]  ForwardC,                 // Forwarding control
    output reg [31:0] op_Forward_Rs1
);

always @(*) begin
    // Highest priority: immediate EX hazard (same cycle dependency)
    if (ip_ID_EX_Rd == ip_IF_ID_Rs1)
        op_Forward_Rs1 = ip_ALU_op;

    else begin
        case (ForwardC)
            2'b10: op_Forward_Rs1 = ip_EX_MEM_ALU_Result;   // EX/MEM
            2'b01: op_Forward_Rs1 = ip_MEM_WB_RegisterRS1;  // MEM/WB
            2'b11: op_Forward_Rs1 = ip_MEM_Read;
            default: op_Forward_Rs1 = ip_IF_ID_RegisterRS1; // No forwarding
        endcase
    end
end

endmodule