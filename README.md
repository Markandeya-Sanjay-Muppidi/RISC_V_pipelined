# RISC-V Pipelined Processor Core

A fully functional 5-stage pipelined RISC-V (RV32I) processor implemented in Verilog, designed and simulated using Xilinx Vivado 2019.2. The design supports hazard detection, data forwarding, and early branch resolution — targeting FPGA deployment.


## Architecture Overview

The processor implements the classic 5-stage pipeline:


IF  →  ID  →  EX  →  MEM  →  WB

- IF  (Instruction Fetch)   : Fetches instruction from Block RAM (BRAM)-based Instruction Memory
- ID  (Instruction Decode)  : Decodes instruction, reads register file, generates immediate, evaluates branch condition
- EX  (Execute)             : Performs ALU operation; computes branch/jump target address
- MEM (Memory Access)       : Reads/writes BRAM-based Data Memory
- WB  (Write Back)          : Selects and writes result back to the register file



## Source Modules

### Top-Level

`Top_module.v` — Module: `Top_Module`
Top-level integration of all pipeline stages and interconnects.
Ports: `clk`, `reset`, `op_WriteBack[31:0]`


### Pipeline Stage Registers

`IF_ID_register.v` — Module: `IF_ID_Register`
IF/ID pipeline register. Supports `flush` on branch taken and `stall` on hazard. Holds the fetched instruction and current PC value.

`ID_EX_Register.v` — Module: `ID_EX_Register`
ID/EX pipeline register. Carries decoded control signals, register data, immediate value, and the instruction word to the EX stage. Supports `flush`.

`EX_MEM_Register.v` — Module: `EX_MEM_Register`
EX/MEM pipeline register. Holds ALU result, write data, memory control signals, and branch resolution output. Supports `flush`.

`MEM_WB_Register.v` — Module: `MEM_WB_Register`
MEM/WB pipeline register. Carries memory read data, ALU result, PC, write-back select signals, and `RegWrite` to the WB stage.


### Instruction Fetch (IF) Stage

`ADD_PC.v` — Module: `Add_PC`
PC adder and register. Increments the program counter by 4 on every clock cycle. Freezes the PC when the `ip_PCWrite` stall signal is asserted.

`MUX_PC.v` — Module: `Mux_PC`
PC select MUX. Selects between the sequential next PC (PC+4) and the branch or jump target address based on `Jump` or `op_Branch_Unit` signals.

`IF_wrapper.v` — Module: `IF_wrapper`
Instruction Memory interface wrapper. Connects to the Xilinx BRAM IP (`IM_wrapper`) on the inverted clock edge. Converts the byte-addressed PC to a word address by right-shifting by 2.



### Instruction Decode (ID) Stage

`Control_Unit.v` — Module: `Control_Unit`
Main control unit. Decodes the 7-bit opcode field and generates all control signals: `RegWrite`, `ALUSrc[1:0]`, `ALUOp[1:0]`, `MemtoReg[1:0]`, `MemRead`, `MemWrite`, `Branch_En`, `Jump`, and `Imm_signal`. Handles R, I, S, B, U (LUI/AUIPC), and J (JAL/JALR) instruction types.

`Reg_file.v` — Module: `Reg_file`
32 x 32-bit general-purpose register file. Synchronous write on rising clock edge, asynchronous read. Ports: `Read_Reg1`, `Read_Reg2`, `Write_Reg`, `RegWrite`, `Data_in`, `Data_out1`, `Data_out2`.

`immediate.v` — Module: `Immediate`
Immediate generator. Sign-extends immediate fields for I, S, B, U, and J instruction types based on the opcode.

`Branch_unit.v` — Module: `Branch_Unit`
Branch condition evaluator, placed in the ID stage for early resolution. Compares `rs1` and `rs2` using `funct3` to evaluate BEQ, BNE, BLT, BGE, BLTU, and BGEU without waiting for the EX stage.

`RS1.v` — Module: `Forward_Unit_RS1`
Forwarding MUX for the Branch Unit RS1 input. Selects between register file output and forwarded pipeline data.

`RS2.v` — Module: `Forward_Unit_RS2`
Forwarding MUX for the Branch Unit RS2 input. Selects between register file output and forwarded pipeline data.



### Execute (EX) Stage

`ALU.v` — Module: `ALU_Unit`
32-bit Arithmetic Logic Unit. Supported operations: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU. Operation is selected via a 6-bit `ALU_Control` signal.

`ALU_control.v` — Module: `ALU_CTRL_UNIT`
ALU control decoder. Derives the 6-bit `ALUCtrl` signal from `ALUOp[1:0]` combined with `funct3` and `funct7` fields of the instruction. Also outputs `branch_in`.

`FU_mux1.v` — Modules: `FU_mux1`, `FU_mux2`
ALU input forwarding MUXes. Select between the original register data, EX-MEM forwarded data, and MEM-WB forwarded data based on `ForwardA` and `ForwardB` signals from the Forwarding Unit.

`Write_Back_MUX.v` — Module: `Write_Back_Mux`
Write-back data selector. Chooses among ALU result, memory read data, and PC+4 (for JAL/JALR return address) based on the 2-bit `sel_MemtoReg` control signal.



### Memory (MEM) Stage

`Data_Memory_Wrapper.v` — Module: `Data_Memory_Wrapper`
Data Memory wrapper around the Xilinx BRAM IP (`d_m_wrapper`). Handles byte, halfword, and word-level memory accesses based on `funct3`. Ports include write address, read address, data input, `MemWrite`, `MemRead`, and `funct3`.


### Hazard and Forwarding Control

`Forwarding_unit.v` — Module: `Forwarding_Unit`
Data forwarding unit. Generates 3-bit `ForwardA` and `ForwardB` signals for EX-stage ALU input selection and 2-bit `ForwardC` and `ForwardD` signals for ID-stage branch comparator forwarding. Covers EX-MEM and MEM-WB forwarding paths, including the load-to-use forwarding case.

`HAZARD_Detection_unit.v` — Module: `Hazard_Detection_Unit`
Hazard detection unit. Detects load-use data hazards, especially when a branch instruction depends on a value being loaded in the previous instruction. Asserts `PCWrite` to stall the pipeline and signals the NOP MUX to insert a bubble.

`NOP_Mux.v` — Module: `NOP_MUX`
NOP insertion MUX. On a detected hazard stall, replaces the decoded control signals with a NOP equivalent (ADDI x0, x0, 0 — encoding `0x00000013`) to prevent the in-flight instruction from causing incorrect state changes.

`Forward_4x2_First.v` — Module: `Forward_4x2_First`
4-to-1 MUX for forwarding data to the Branch Unit RS1 comparator input.

`Forward_4x2_Second.v` — Module: `Forward_4x2_Second`
4-to-1 MUX for forwarding data to the Branch Unit RS2 comparator input.



### Memory IPs (Block Designs)

`IM` — Instruction Memory
Xilinx Block Memory Generator IP (v8.4), configured as a single-port BRAM for instruction storage. Memory contents are initialized via `instructions.coe`.

`d_m` — Data Memory
Xilinx Block Memory Generator IP (v8.4), configured as a dual-port BRAM to support simultaneous read and write access for the MEM stage.

---

### Shared Parameter File

`Parameters.vh`
Defines all 6-bit ALU control codes used across the design. Covers every supported operation: ADD, SUB, AND, OR, XOR, SLL, SLT, SLTU, SRL, SRA, LB, LBU, LH, LHU, LW, JAL, SB, SH, SW, BEQ, BNE, BLT, BGE, BLTU, BGEU, LUI, AUIPC.

---

### Simulation and Testbench

`RISC_V_trail.srcs/sim_1/new/tb.v`
Top-level testbench module (`tb`). Instantiates `Top_Module`, generates the clock signal, applies reset, and monitors `op_WriteBack` for functional verification.

`instructions.coe`
Coefficient initialization file used to preload the Instruction Memory BRAM with test program instructions.

---

## Supported Instructions

- R-Type : ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
- I-Type : ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU
- Load   : LB, LBU, LH, LHU, LW
- Store  : SB, SH, SW
- Branch : BEQ, BNE, BLT, BGE, BLTU, BGEU
- Upper  : LUI, AUIPC
- Jump   : JAL, JALR



## Hazard Handling

Data Hazards
Resolved through full forwarding. The Forwarding Unit detects when a result produced in EX or MEM can be directly forwarded to the ALU inputs (ForwardA, ForwardB) or to the ID-stage branch comparator (ForwardC, ForwardD), avoiding unnecessary stalls.

Load-Use Hazards
When a load instruction is immediately followed by an instruction that uses the loaded value, the Hazard Detection Unit freezes the PC and IF/ID register for one cycle and inserts a NOP bubble into the ID/EX register.

Control Hazards
Branches are evaluated early in the ID stage by the Branch Unit, reducing the branch penalty to 1 cycle. When a branch is taken, the flush signal clears the IF/ID pipeline register to discard the incorrectly fetched instruction.



## Tools and Target

- HDL         : Verilog (IEEE 1364-2001)
- EDA Tool    : Xilinx Vivado 2019.2
- Simulator   : Vivado XSim (Behavioral Simulation)
- Memory IPs  : Xilinx Block Memory Generator v8.4
- Target FPGA : Xilinx 7-Series (project synthesized and implemented)




## Getting Started

1. Clone the repository and open Vivado 2019.2.
2. Open the project via File → Open Project and select `RISC_V_trail.xpr`.
3. To run behavioral simulation, set `tb.v` as the top simulation source and go to Flow → Run Simulation.
4. To load custom instructions, edit `instructions.coe` with your RISC-V machine code and re-generate the Instruction Memory IP.
5. For FPGA deployment, run synthesis and implementation using the Vivado flow.


## Simulation

The waveform configuration is saved in `Simulation_Result.wcfg`. After running simulation, load this file in the Vivado waveform viewer to inspect all pipeline-stage signals across IF, ID, EX, MEM, and WB.


## Notes

- Branch resolution happens in the ID stage, keeping the branch penalty to a single cycle.
- The PC and all pipeline registers use synchronous reset.
- The Instruction Memory BRAM is driven on the inverted clock edge so the fetched instruction is ready at the start of the next cycle.
- The top-level `op_WriteBack` output exposes the write-back data (ALU result, memory load value, or PC+4) for simulation observability.


