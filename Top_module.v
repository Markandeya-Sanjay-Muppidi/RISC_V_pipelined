`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/31/2024 07:11:56 PM
// Design Name: 
// Module Name: Top_Module
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
module Top_Module(clk, reset, op_WriteBack);
    input clk;
    input reset;
    output [31:0] op_WriteBack;
    
//<--------------------------Signals----------------------------->//
    wire [31:0] Instruction;
    wire [7:0] w_PC_Add; 
    wire  [31:0] w_PC_Add_temp ;
    wire w_RegWrite;
    wire [1:0] w_ALUSrc;
    wire [31:0] w_Data_out2;
    wire [31:0] w_imm;
    wire [31:0] w_Data_out1;
    wire [31:0] w_Mux_Data; 
    wire [1:0]  w_ALUOp;
    wire [5:0] w_ALUCtrl;
    wire [31:0] w_Read_Data;
    wire [1:0] w_sel_MemtoReg;
    wire w_MemRead;
    wire w_MemWrite;
    wire [31:0] w_alu_output;
    wire [31:0] w_Muc_PC;
    wire [31:0] op_ADD_J;
    wire w_Branch_En;
    wire w_op_Branch_Unit;
    wire [31:0] pc_temp ;
    wire w_Jump;
    wire Imm_signal; 
    wire [31:0] w_FU_mux_Data_out1;
    wire [31:0] w_FU_mux_Data_out2;
//<-------------------------------------------------------------->//
//<-------------------PIPELINE SIGNAL------------------------------>
//<--------------IF-ID-Output Signal------------------------------->
    wire [31:0] IF_ID_Instruction;
    wire [31:0] IF_ID_w_PC_Add_temp;
    wire [31:0] IF_ID_PC_temp;
//<--------------ID-EX-Output Signal------------------------------->
    wire [31:0] ID_EX_w_PC_ADD_temp;
    wire [31:0] ID_EX_PC_temp;
    wire [31:0] ID_EX_Data_out1;
    wire [31:0] ID_EX_Data_out2;
    wire [31:0] ID_EX_Immediate;
    wire [31:0] ID_EX_Instruction;
    wire [1:0] ID_EX_ALUSrc;
    wire [1:0] ID_EX_ALUOp;
    wire [1:0] ID_EX_MemtoReg;
    wire ID_EX_MemRead;
    wire ID_EX_MemWrite;
    wire ID_EX_Branch_Unit;
    wire ID_EX_OR_Branch_en;
    wire ID_EX_C_Write;
    wire ID_EX_Imm_signal;
//<-------------EX-MEM-Output Signal------------------------------>
    wire [31:0] EX_MEM_ADD_J;
    wire [31:0] EX_MEM_ALU;
    wire [31:0] EX_MEM_Data_out2;
    wire EX_MEM_Branch_Unit;
    wire EX_MEM_OR_Branch_en;
    wire [31:0] EX_MEM_w_PC_ADD_temp;
    wire EX_MEM_MemWrite;
    wire EX_MEM_MemRead;
    wire [1:0] EX_MEM_MemtoReg;
    wire [31:0] EX_MEM_Instruction;
    wire EX_MEM_C_Write;
    wire EX_MEM_Imm_signal;
    wire [31:0] EX_MEM_Data_out1;
//<---------------MEM-WB-Output Signal---------------------------->
    wire [31:0] MEM_WB_Read_Data;
    wire [31:0] MEM_WB_alu_Result;
    wire [31:0] MEM_WB_PC;
    wire [1:0] MEM_WB_MemtoReg;
    wire [31:0] MEM_WB_Instruction;
    wire MEM_WB_C_Write;
//<-------------------------------------------------------------->  
//<---------------Hazard Signals--------------------------------->
    wire [10:0] op_NOP_MUX;
    wire sel_NOP_MUX;
    wire [2:0] w_ForwardB;
    wire [2:0] w_ForwardA;
    wire [31:0] w_U_Data_out1;
    wire w_ip_PCWrite;
    wire w_op_Branch;
    wire [1:0] w_ForwardC;
    wire [1:0] w_ForwardD;
    wire [31:0] w_4x2_Mux_Data_out1;
    wire [31:0] w_4x2_Mux_Data_out2;
    wire w_JALR;
    wire w_PCSrc;
    wire Hazard_op;

    assign w_PCSrc = w_JALR                         ? 2'b10 :
                     (w_op_Branch_Unit || w_Jump)    ? 2'b01 :
                                                       2'b00;
//    assign w_ID_target = (IF_ID_w_PC_Add_temp - 32'd4) + w_imm;
    
    
//    assign w_ID_EX_PC_actual = ID_EX_w_PC_ADD_temp - 32'd4;

    wire [31:0] w_StoreData;
    assign w_StoreData =
        ((EX_MEM_C_Write) &&
         (EX_MEM_Instruction[11:7] != 0) &&
         (EX_MEM_Instruction[11:7] == ID_EX_Instruction[24:20])) ? EX_MEM_ALU   :
        ((MEM_WB_C_Write) &&
         (MEM_WB_Instruction[11:7] != 0) &&
         (MEM_WB_Instruction[11:7] == ID_EX_Instruction[24:20])) ? op_WriteBack :
        ID_EX_Data_out2;

//<-------------------------------------------------------------->
    // 1.> Instantiate Control Module
    Control_Unit CU(
        .Instruction(IF_ID_Instruction),
        .RegWrite(w_RegWrite),
        .ALUSrc(w_ALUSrc),
        .ALUOp(w_ALUOp),
        .MemtoReg(w_sel_MemtoReg),
        .MemRead(w_MemRead),
        .MemWrite(w_MemWrite),
        .Branch_En(w_Branch_En),
        .Jump(w_Jump),
        .Imm_signal(Imm_signal)
    );

    // 2.> Instantiate Register File
    Reg_file Reg(
        .Read_Reg1(IF_ID_Instruction[19:15]),
        .Read_Reg2(IF_ID_Instruction[24:20]),
        .Write_Reg(MEM_WB_Instruction[11:7]),
        .RegWrite(MEM_WB_C_Write),
        .clk(clk),
        .reset(reset),
        .Data_out1(w_Data_out1),
        .Data_out2(w_Data_out2),
        .Data_in(op_WriteBack)
    );

    // 3.> Instantiate Immediate Generator
    Immediate Imm(
        .instruction(IF_ID_Instruction[31:0]),
        .immediate(w_imm)
    );

    // 4.> Instantiate MUX between Register File and Immediate (RS2 side)
    Reg_Mux_ALU M0(
        .ip_Data_out2(ID_EX_Data_out2),
        .ip_Imm_Gen(ID_EX_Immediate),
        .Data_out(w_Mux_Data),
        .ip_MEM_Read(w_Read_Data),
        .ip_EX_MEM_ALU_Result(EX_MEM_ALU),
        .sel_ForwardB(w_ForwardB),
        .ip_MEM_WB_WriteBack(op_WriteBack)
    );

    // Instantiate MUX between ALU and first output of Register File (RS1 side)
    U_Reg_Mux_ALU M1(
        .ip_Data_out1(ID_EX_Data_out1),
        .ip_EX_MEM_ALU_Result(EX_MEM_ALU),
        .sel_ForwardA(w_ForwardA),
        .ip_MEM_Read(w_Read_Data),
        .op_PC(ID_EX_w_PC_ADD_temp),
        .ip_MEM_WB_WriteBack(op_WriteBack),
        .op_Data_out1(w_U_Data_out1)
    );

    // 5.> Instantiate ALU
    ALU_Unit AU(
        .Read_data1(w_U_Data_out1),
        
        .Mux_Data(w_Mux_Data),
        .ALU_Control(w_ALUCtrl),
        .ALU_Result(w_alu_output)
    );

    // 6.> Instantiate ALU Control Unit
    ALU_CTRL_UNIT AC(
        .Instruction(ID_EX_Instruction[31:0]),
        .ALUOp(ID_EX_ALUOp),
        .ALUCtrl(w_ALUCtrl)
    );

    // 7.> Instantiate Data Memory
    Data_Memory_Wrapper DM(
        .BRAM_PORTA_0_addr(EX_MEM_ALU),
        .i_clk(clk),
        .BRAM_PORTA_0_din(EX_MEM_Data_out2),
        .BRAM_PORTB_0_addr(EX_MEM_ALU),
        .MemWrite(EX_MEM_MemWrite),
        .MemRead(EX_MEM_MemRead),
        .funct3(EX_MEM_Instruction[14:12]),
        .BRAM_PORTB_Wr_out(w_Read_Data)
    );

    // 8.> Instantiate Write Back MUX
    Write_Back_Mux WB(
        .ip_alu_result(MEM_WB_alu_Result),
        .ip_Read_Data(MEM_WB_Read_Data),
        .sel_MemtoReg(MEM_WB_MemtoReg),
        .op_Writeback_mux(op_WriteBack),
        .op_PC(MEM_WB_PC)
    );

    // 9.> Instantiate Instruction Fetch Wrapper
    IF_wrapper IF(
        .ip_PC_Add(w_Muc_PC),
        .clk(clk),
        .op_IF(Instruction)
    );

    // 10.> Instantiate PC
    Add_PC PC(
        .ip_add(w_Muc_PC),
        .ip_rst(reset),
        .ip_clk(clk),
        .ip_PCWrite(w_ip_PCWrite),
        .op_add(w_PC_Add_temp)
    );

    // 11.> Instantiate PC Mux
    Mux_PC PCA(
        .ip_Add_PC(w_PC_Add_temp),
//        .ip_Add_J(w_ID_target),
//        .ip_Add_J(EX_MEM_ALU),
        .ip_Add_J(w_alu_output),
        .Jump(w_Jump),
        .op_Branch_Unit(EX_MEM_Branch_Unit),
//        .sel_PCSrc(w_PCSrc),
        .op_Mux_pc(w_Muc_PC)
    );

    // 13.> Instantiate Branch Unit
    Branch_Unit BU(
        .Instruction(IF_ID_Instruction),
        .ip_read_data1(w_FU_mux_Data_out1),
        .ip_read_data2(w_FU_mux_Data_out2),
        .Branch_ip(w_Branch_En),
        .op_Branch_Unit(w_op_Branch_Unit)
    );

    //<--------------------------Pipelining-------------------------------->
    //<-------------------IF/ID Stage------------------------------------->
    IF_ID_Register IF_ID(
        .clk(clk),
        .reset(reset),
        .flush(ID_EX_Branch_Unit),
        .stall(Hazard_op),
        .ip_instruction(Instruction),
        .ip_pc(w_PC_Add_temp),
        .op_pc(IF_ID_w_PC_Add_temp),
        .op_instruction(IF_ID_Instruction)
    );

    //<--------------------ID/EX----------------------------------------->
    ID_EX_Register ID_EX(
        .clk(clk),
        .reset(reset),
        .flush(ID_EX_Branch_Unit),
        .ip_IF_ID_PC(IF_ID_w_PC_Add_temp),
        .ip_Data_out1(w_Data_out1),
        .ip_Data_out2(w_Data_out2),
        .ip_immediate(w_imm),
        .ip_Instruction(IF_ID_Instruction),
        .ip_ALUSrc(op_NOP_MUX[1:0]),
        .ip_ALUOp(op_NOP_MUX[3:2]),
        .ip_MemRead(op_NOP_MUX[7]),
        .ip_MemWrite(op_NOP_MUX[8]),
        .ip_MemtoReg(op_NOP_MUX[5:4]),
        .ip_Branch_Unit(w_op_Branch_Unit || w_Jump),
        .ip_RegWrite(op_NOP_MUX[10]),
        .ip_Imm_signal(Imm_signal),
        .op_Imm_signal(ID_EX_Imm_signal),
        .op_RegWrite(ID_EX_C_Write),
        .op_Branch_Unit(ID_EX_Branch_Unit),
        .op_ALUSrc(ID_EX_ALUSrc),
        .op_ALUOp(ID_EX_ALUOp),
        .op_MemRead(ID_EX_MemRead),
        .op_MemWrite(ID_EX_MemWrite),
        .op_MemtoReg(ID_EX_MemtoReg),
        .op_ID_EX_PC(ID_EX_w_PC_ADD_temp),
        .op_ID_EX_Data_out1(ID_EX_Data_out1),
        .op_ID_EX_Data_out2(ID_EX_Data_out2),
        .op_immediate(ID_EX_Immediate),
        .op_Instruction(ID_EX_Instruction)
    );

    //<-------------------EX/MEM----------------------------------------->
    EX_MEM_Register EX_MEM(
        .clk(clk),
        .reset(reset),
//        .flush(EX_MEM_Branch_Unit),
        .ip_PC(ID_EX_w_PC_ADD_temp),
        .ip_ALU(w_alu_output),
        .ip_Data_out2(w_StoreData),
        .ip_Branch_Unit(ID_EX_Branch_Unit),
        .ip_MemWrite(ID_EX_MemWrite),
        .ip_MemRead(ID_EX_MemRead),
        .ip_MemtoReg(ID_EX_MemtoReg),
        .ip_Instruction(ID_EX_Instruction),
        .ip_RegWrite(ID_EX_C_Write),
        .ip_Imm_signal(ID_EX_Imm_signal),
        .ip_Data_out1(ID_EX_Data_out1),
        .op_Data_out1(EX_MEM_Data_out1),
        .op_Imm_signal(EX_MEM_Imm_signal),
        .op_RegWrite(EX_MEM_C_Write),
        .op_Instruction(EX_MEM_Instruction),
        .op_MemWrite(EX_MEM_MemWrite),
        .op_MemRead(EX_MEM_MemRead),
        .op_MemtoReg(EX_MEM_MemtoReg),
        .op_EX_MEM_ALU(EX_MEM_ALU),
        .op_EX_MEM_Data_out2(EX_MEM_Data_out2),
        .op_Branch_Unit(EX_MEM_Branch_Unit),
        .op_EX_MEM_PC(EX_MEM_w_PC_ADD_temp)
    );

    //<----------------MEM/WB------------------------------------------>
    MEM_WB_Register MEM_WB(
        .clk(clk),
        .reset(reset),
        .ip_Read_Data(w_Read_Data),
        .ip_alu_Result(EX_MEM_ALU),
        .ip_PC(EX_MEM_w_PC_ADD_temp),
        .ip_MemtoReg(EX_MEM_MemtoReg),
        .ip_Instruction(EX_MEM_Instruction),
        .ip_RegWrite(EX_MEM_C_Write),
        .op_RegWrite(MEM_WB_C_Write),
        .op_Instruction(MEM_WB_Instruction),
        .op_Read_Data(MEM_WB_Read_Data),
        .op_alu_Result(MEM_WB_alu_Result),
        .op_PC(MEM_WB_PC),
        .op_MemtoReg(MEM_WB_MemtoReg)
    );

    //<---------------------Hazards-------------------------------------->
    //<----------------Control Hazard Unit------------------------------->
    Hazard_Detection_Unit HDU(
        .ip_IF_ID_RegisterRS1(IF_ID_Instruction[19:15]),
        .ip_IF_ID_RegisterRS2(IF_ID_Instruction[24:20]),
        .ip_ID_EX_RegisterRD(ID_EX_Instruction[11:7]),
        .ip_ID_EX_MemRead(ID_EX_MemRead),
        .ip_OR_Branch(w_Branch_En || w_Jump || w_JALR),
        .ip_ForwardC(w_ForwardC),
        .ip_ForwardD(w_ForwardD),
        .ip_ForwardC2(w_ForwardC2),
        .ip_ForwardD2(w_ForwardD2),
        .ip_PCWrite(w_ip_PCWrite),
        .op_Hazard_Unit(Hazard_op)
    );

    //<----------------NOP MUX------------------------------------------->
    NOP_MUX NOP(
        .ip_NOP_Instruction(10'h0),
        .sel_Hazard_Unit(1'b0),
        .ALUSrc(w_ALUSrc),
        .ALUOp(w_ALUOp),
        .MemtoReg(w_sel_MemtoReg),
        .MemRead(w_MemRead),
        .MemWrite(w_MemWrite),
        .ip_OR_Branch_en(w_op_Branch_Unit || w_Jump ),
        .ip_RegWrite(w_RegWrite),
        .op_NOP_MUX(op_NOP_MUX)
    );

    //<------------------Forwarding Unit----------------------------------->
//    Forwarding_Unit FU(
//        .ip_ID_EX_RegisterRS1(ID_EX_Instruction[19:15]),
//        .ip_ID_EX_RegisterRS2(ID_EX_Instruction[24:20]),
//        .ip_EX_MEM_RegisterRD(EX_MEM_Instruction[11:7]),
//        .ip_MEM_WB_RegisterRD(MEM_WB_Instruction[11:7]),
//        .ip_MEM_WB_RegWrite(MEM_WB_C_Write),
//        .ip_EX_MEM_RegWrite(EX_MEM_C_Write),
//        .ip_Imm_signal(EX_MEM_Imm_signal),
//        .op_ForwardA(w_ForwardA),
//        .op_ForwardB(w_ForwardB),
//        .sel_ALUSrc(ID_EX_ALUSrc),
//        .op_ForwardC(w_ForwardC),
//        .op_ForwardD(w_ForwardD),
//        .op_ForwardC2(w_ForwardC2),
//         .op_ForwardD2(w_ForwardD2)
//        // REMOVED: ip_IF_ID_RegisterRS1, ip_IF_ID_RegisterRS2, op_ForwardC2, op_ForwardD2
//        // These do not exist in your Forwarding_Unit module definition.
//    );
    //<------------------Forwarding Unit---------------------------->
    Forwarding_Unit FU(
    .ip_ID_EX_RegisterRS1(ID_EX_Instruction[19:15]),
    .ip_ID_EX_RegisterRS2(ID_EX_Instruction[24:20]),
    .ip_EX_MEM_RegisterRD(EX_MEM_Instruction[11:7]),
    .ip_MEM_WB_RegisterRD(MEM_WB_Instruction[11:7]),
    .ip_MEM_WB_RegWrite(MEM_WB_C_Write),
    .ip_EX_MEM_RegWrite(EX_MEM_C_Write),
    .ip_Imm_signal(EX_MEM_Imm_signal),
    .ip_EX_MEM_MemRead(EX_MEM_MemRead),
    .op_ForwardA(w_ForwardA),
    .op_ForwardB(w_ForwardB),
    .sel_ALUSrc(ID_EX_ALUSrc),
    .op_ForwardC(w_ForwardC),
    .op_ForwardD(w_ForwardD),
    .ip_ID_EX_Opcode(ID_EX_Instruction[6:0]),
    // NEW: IF_ID rs1/rs2 for correct branch stage forwarding
    .ip_IF_ID_RegisterRS1(IF_ID_Instruction[19:15]),
    .ip_IF_ID_RegisterRS2(IF_ID_Instruction[24:20])
    );
    //<----------------------------------------------------------------->

    // Instantiate MUX-1 before Branch for Forwarding from 4 to 2
    // RS1 Forwarding Unit
    Forward_Unit_RS1 FU_RS1 (
        .ip_IF_ID_RegisterRS1 (w_Data_out1),
        .ip_EX_MEM_ALU_Result (EX_MEM_ALU),
        .ip_MEM_WB_RegisterRS1 (op_WriteBack),
        .ip_ALU_op            (w_alu_output),
        .ip_ID_EX_Rd          (ID_EX_Instruction[11:7]),
        .ip_IF_ID_Rs1         (IF_ID_Instruction[19:15]),
        .ip_MEM_Read(w_Read_Data),
        .ForwardC             (w_ForwardC),   // now 2-bit
        .op_Forward_Rs1       (w_FU_mux_Data_out1)
    );
    
    // RS2 Forwarding Unit
    Forward_Unit_RS2 FU_RS2 (
        .ip_IF_ID_RegisterRS2 (w_Data_out2),
        .ip_EX_MEM_ALU_Result (EX_MEM_ALU),
        .ip_MEM_WB_RegisterRS2 (op_WriteBack),
        .ip_ALU_op            (w_alu_output),
        .ip_ID_EX_Rd          (ID_EX_Instruction[11:7]),
        .ip_IF_ID_Rs2         (IF_ID_Instruction[24:20]),
        .ip_MEM_Read(w_Read_Data),
        .ForwardD             (w_ForwardD),   // now 2-bit
        .op_Forward_Rs2       (w_FU_mux_Data_out2)
    );
    
endmodule