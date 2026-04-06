module IF_wrapper(ip_PC_Add,op_IF,clk);
    //<-------------------PORT DECLARATION---------------------->
    input [7:0] ip_PC_Add;
    input clk;
//    input reset;
    output [31:0] op_IF;
    wire [7:0] ip_Pc_Add_temp; 
    assign ip_Pc_Add_temp = ip_PC_Add >> 2;
    //<---------wire---------->
    //wire [31:0] w_op_IF;
    // Instantiate the IM Module
    IM_wrapper IM(
    .BRAM_PORTA_0_addr(ip_Pc_Add_temp),
//    .BRAM_PORTA_0_clk(clk), 
    .BRAM_PORTA_0_clk(!clk), 
    .BRAM_PORTA_0_din(32'h0), 
    .BRAM_PORTA_0_dout(op_IF),
    .BRAM_PORTA_0_we(1'b0)
//    .BRAM_PORTA_0_rst(reset)
    );
endmodule