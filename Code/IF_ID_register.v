module IF_ID_Register(
    input clk,
    input reset,
    input flush,                  // NEW: clear to NOP on branch taken
    input stall,                  // NEW: freeze during hazard stall
    input [31:0] ip_instruction,
    input [31:0] ip_pc,
    output reg [31:0] op_instruction,
    output reg [31:0] op_pc
);
    always @(posedge clk or posedge flush) begin
        if (reset || flush) begin
            op_instruction <= 32'b0;
            op_pc          <= 32'b0;
        end
        else if (stall) begin
            op_instruction <= op_instruction;
            op_pc          <= op_pc;
        end
        else  begin
            op_instruction <= ip_instruction;
            op_pc          <= ip_pc;
        end
    end
endmodule