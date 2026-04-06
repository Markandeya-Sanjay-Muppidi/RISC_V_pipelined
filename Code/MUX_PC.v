module Mux_PC(
    input  [31:0] ip_Add_PC,    // normal next PC (PC+4)
    input  [31:0] ip_Add_J,     // JAL / branch targettarget
    input  Jump,    // 2-bit select
    input op_Branch_Unit ,
    output reg [31:0] op_Mux_pc
);
    always @(*) begin
        case(Jump|| op_Branch_Unit)
            1'b0:   op_Mux_pc = ip_Add_PC;    // normal
            1'b1:   op_Mux_pc = ip_Add_J;     // JAL / branch
            default: op_Mux_pc = ip_Add_PC;
        endcase
    end
endmodule