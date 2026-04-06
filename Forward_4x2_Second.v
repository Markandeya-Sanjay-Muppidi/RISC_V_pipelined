`timescale 1ns / 1ps

module Forward_Unit_RS2(
    input [31:0] ip_IF_ID_RegisterRS2,     // Raw value from Register File
    input [31:0] ip_EX_MEM_ALU_Result,     // EX/MEM stage result
    input [31:0] ip_MEM_WB_RegisterRS2,    // MEM/WB stage result
    input [31:0] ip_ALU_op,                // ID/EX stage ALU result (latest)
    input [4:0]  ip_ID_EX_Rd,              // Destination register (ID/EX)
    input [4:0]  ip_IF_ID_Rs2,             // Source register (IF/ID)
    input [1:0]  ForwardD,                 // Combined forwarding control
    input [31:0] ip_MEM_Read,
    output reg [31:0] op_Forward_Rs2
);

always @(*) begin
    // Highest priority: immediate EX hazard
    if (ip_ID_EX_Rd == ip_IF_ID_Rs2)
        op_Forward_Rs2 = ip_ALU_op;

    else begin
        case (ForwardD)
            2'b10: op_Forward_Rs2 = ip_EX_MEM_ALU_Result;   // EX/MEM
            2'b01: op_Forward_Rs2 = ip_MEM_WB_RegisterRS2;  // MEM/WB
            2'b11: op_Forward_Rs2 = ip_MEM_Read;
            default: op_Forward_Rs2 = ip_IF_ID_RegisterRS2; // No forwarding
        endcase
    end
end

endmodule