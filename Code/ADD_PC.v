module Add_PC(ip_clk,ip_rst,ip_add,ip_PCWrite,op_add
//pc_temp,

//ip_delay_Branch
);
//<--------------PORT DECLARATION------------------------------->
    input [31:0] ip_add;  
    input ip_clk;                     // Output from PC 
    input ip_rst;   
    input ip_PCWrite ;                  // Output from PC 
    output reg [31:0] op_add;                // Output of ADDER

    //<-----------------------ADD----------------------------->

always @ (posedge ip_clk)begin 
    if(ip_rst)begin
        op_add<=32'd0; 
    end
    else begin
        if(!ip_PCWrite)begin 
            op_add<= ip_add + 32'd4;
        end
        else begin 
            op_add <= op_add;
        end
    end
end
endmodule