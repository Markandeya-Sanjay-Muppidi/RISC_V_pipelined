`timescale 1ns / 1ps

module tb();

    reg clk;
    reg reset;
    reg we;
    reg [7:0] wr_addr;
    reg [31:0] wr_data;
    reg Reg_File_Read_En;
    reg [4:0] Reg_File_Read_addr;

    wire [31:0] Reg_File_Read_data;

    //-----------------------------------------
    // DUT
    //-----------------------------------------
    Top_module DUT(
        .clk(clk),               
        .reset(reset),   
        .we(we),
        .wr_addr(wr_addr),
        .wr_data(wr_data),  
        .Reg_File_Read_En(Reg_File_Read_En),
        .Reg_File_Read_addr(Reg_File_Read_addr),
        .Reg_File_Read_data(Reg_File_Read_data)
    );

    //-----------------------------------------
    // Clock Generation (10ns period)
    //-----------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //-----------------------------------------
    // Reset + Stimulus
    //-----------------------------------------
    initial begin
        // Initial values
        reset = 1;
        we = 0;
        wr_addr = 0;
        wr_data = 0;
        Reg_File_Read_En = 1;
        Reg_File_Read_addr = 0;

        // Hold reset for few cycles
        #11;
        reset = 0;

        // Let processor run
        #300;

        // Try reading registers
        // Reg_File_Read_addr = 5'd1; #10;
        // Reg_File_Read_addr = 5'd2; #10;
        Reg_File_Read_addr = 5'd7; #10;
        Reg_File_Read_addr = 5'd6; #10;
        Reg_File_Read_addr = 5'd5; #10;

        #100;
        $finish;
    end

    //-----------------------------------------
    // VCD Dump (VERY IMPORTANT)
    //-----------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    //-----------------------------------------
    // Monitor Important Signals
    //-----------------------------------------
    initial begin
        $monitor("Time=%0t | PC=%h | Instr=%h | RegData=%h",
                  $time,
                  DUT.w_Muc_PC,
                  DUT.Instruction,
                  Reg_File_Read_data);
    end

endmodule
