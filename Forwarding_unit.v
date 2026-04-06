
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Forwarding_Unit
// Fix: ForwardC and ForwardD now correctly compare against IF_ID rs1/rs2
//      (Branch Unit is in ID stage, not EX stage)
//      Split into separate always blocks so both can fire independently
//      Added ForwardC2/ForwardD2 for MEM_WB -> Branch forwarding (2 cycles ahead)
//////////////////////////////////////////////////////////////////////////////////

module Forwarding_Unit(
    input [4:0] ip_ID_EX_RegisterRS1,
    input [4:0] ip_ID_EX_RegisterRS2,
    input [4:0] ip_EX_MEM_RegisterRD,
    input [4:0] ip_MEM_WB_RegisterRD,
    input ip_MEM_WB_RegWrite,
    input ip_EX_MEM_RegWrite,
    input [1:0] sel_ALUSrc,
    input ip_Imm_signal,
    input [6:0] ip_ID_EX_Opcode,
    // NEW: IF_ID rs1/rs2 for branch forwarding
    input [4:0] ip_IF_ID_RegisterRS1,
    input [4:0] ip_IF_ID_RegisterRS2,
    input ip_EX_MEM_MemRead,
    output reg [2:0] op_ForwardA,
    output reg [2:0] op_ForwardB,
    output reg [1:0] op_ForwardC,   // EX_MEM -> Branch RS1
    output reg [1:0] op_ForwardD   // EX_MEM -> Branch RS2
);

    //<--------- ForwardA: ALU input 1 forwarding (unchanged) --------->
    always @(*) begin
        if (ip_ID_EX_Opcode == 7'b0110111) begin   // LUI
        op_ForwardA <= 3'b010;
        end
        else if (ip_ID_EX_Opcode == 7'b0010111) begin  // AUIPC
        op_ForwardA <= 3'b011;
        end
       else if ((ip_EX_MEM_MemRead) &&   // previous instruction is lw
                 (ip_EX_MEM_RegisterRD != 0) &&
                 (ip_EX_MEM_RegisterRD == ip_ID_EX_RegisterRS1))
            op_ForwardA = 3'b111;   // <-- new control code (memory output)
         
            
        else if ((ip_EX_MEM_RegWrite) &&
            (ip_EX_MEM_RegisterRD != 0) &&
            (ip_EX_MEM_RegisterRD == ip_ID_EX_RegisterRS1))
            op_ForwardA = 3'b110;

        else if ((ip_MEM_WB_RegWrite) &&
            (ip_MEM_WB_RegisterRD != 0) &&
            (ip_MEM_WB_RegisterRD == ip_ID_EX_RegisterRS1))
            op_ForwardA = 3'b101;
        else
            op_ForwardA = 3'b000;
    end

    //<--------- ForwardB: ALU input 2 forwarding (unchanged) --------->
    always @(*) begin
        if ((ip_EX_MEM_RegWrite && !ip_Imm_signal) &&
            (ip_EX_MEM_RegisterRD != 0) &&
            (ip_EX_MEM_RegisterRD == ip_ID_EX_RegisterRS2))
            op_ForwardB = 3'b110;   
            
        else if ((ip_EX_MEM_MemRead) &&   // previous instruction is lw
             (ip_EX_MEM_RegisterRD != 0) &&
             (ip_EX_MEM_RegisterRD == ip_ID_EX_RegisterRS2))
        op_ForwardB = 3'b111;   // <-- new control code (memory output)

        else if ((ip_MEM_WB_RegWrite) &&
            (ip_MEM_WB_RegisterRD != 0) &&
            !(ip_EX_MEM_RegWrite && (ip_EX_MEM_RegisterRD != 0) &&
              (ip_EX_MEM_RegisterRD == ip_ID_EX_RegisterRS2)) &&
            (ip_MEM_WB_RegisterRD == ip_ID_EX_RegisterRS2))
            op_ForwardB = 3'b101;
        else
            op_ForwardB = {1'b0, sel_ALUSrc};
    end

    always @(*) begin
    // Default: no forwarding
    op_ForwardC = 2'b00;
    op_ForwardD = 2'b00;

    // -------------------------
    // RS1 Forwarding (ForwardC)
    // -------------------------
    if ((ip_EX_MEM_MemRead) &&   // previous instruction is lw
         (ip_EX_MEM_RegisterRD != 0) &&
         (ip_EX_MEM_RegisterRD == ip_IF_ID_RegisterRS1))
         
        op_ForwardC = 2'b11;   // EX/MEM has priority
        
    else if (ip_EX_MEM_RegWrite &&
        ip_EX_MEM_RegisterRD != 5'b0 &&
        ip_EX_MEM_RegisterRD == ip_IF_ID_RegisterRS1)
        
        op_ForwardC = 2'b10;   // EX/MEM has priority

    else if (ip_MEM_WB_RegWrite &&
             ip_MEM_WB_RegisterRD != 5'b0 &&
             ip_MEM_WB_RegisterRD == ip_IF_ID_RegisterRS1)
        
        op_ForwardC = 2'b01;   // MEM/WB
        
//    else if ((ip_EX_MEM_MemRead) &&   // previous instruction is lw
//         (ip_EX_MEM_RegisterRD != 0) &&
//         (ip_EX_MEM_RegisterRD == ip_IF_ID_RegisterRS1))
         
//        op_ForwardC = 2'b11;   // EX/MEM has priority
    else
            op_ForwardC = 2'b00;   // EX/MEM has priority

    // -------------------------
    // RS2 Forwarding (ForwardD)
    // -------------------------
    if ((ip_EX_MEM_MemRead) &&   // previous instruction is lw
         (ip_EX_MEM_RegisterRD != 0) &&
         (ip_EX_MEM_RegisterRD == ip_IF_ID_RegisterRS2))
         
        op_ForwardD = 2'b11;   // EX/MEM has priority
        
    else if (ip_EX_MEM_RegWrite &&
        ip_EX_MEM_RegisterRD != 5'b0 &&
        ip_EX_MEM_RegisterRD == ip_IF_ID_RegisterRS2)
        
        op_ForwardD = 2'b10;   // EX/MEM has priority

    else if (ip_MEM_WB_RegWrite &&
             ip_MEM_WB_RegisterRD != 5'b0 &&
             ip_MEM_WB_RegisterRD == ip_IF_ID_RegisterRS2)
        
        op_ForwardD = 2'b01;   // MEM/WB
     
//    else if ((ip_EX_MEM_MemRead) &&   // previous instruction is lw
//         (ip_EX_MEM_RegisterRD != 0) &&
//         (ip_EX_MEM_RegisterRD == ip_IF_ID_RegisterRS2))
         
//        op_ForwardD = 2'b11;   // EX/MEM has priority
    else
            op_ForwardD = 2'b00;   // EX/MEM has priority

end
endmodule