// Top Level CPU Module

module CPU (
    input logic clk,
    input logic reset
);

    // ------------------------------------------FETCH-------------------------------------------- //
    logic [7:0] pc;

    IF_module fetch (
        .Branch(branch_taken),
        .Target(branch_target),
        .Init(reset),
        .Stall(stall),
        .CLK(clk),
        .PC(pc)
    );

    logic [8:0] instr;

    InstructionMemory instructionMem(
        .address(pc),
        .instruction(instr)
    );

    // Placeholder wires for connecting modules
    // Declare wires for IF/ID outputs, ID/EX inputs, EX/MEM, MEM/WB, etc.
    // Declare all ControlSignals structs needed

    // === IF/ID REGISTER ===
    // TODO: Instantiate and wire up IF/ID register here
    logic [7:0] ifId_pc_out;
    logic [8:0] ifId_instr_out;

    IF_ID ifIdReg(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),
        .PC_in(pc),
        .instr_in(instr),
        .PC_out(ifId_pc_out),
        .instr_out(ifId_instr_out)
    );

    // ---------------------------------------DECODE--------------------------------------//

    // === CONTROL UNIT ===
    // TODO: Instantiate Control and HazardControlMUX
    ControlSignals control_ctrl_out;

    Control control(
        .init(reset),
        .instruction(ifId_instr_out),
        .ctrl(control_ctrl_out)
    );

    ControlSignals hcMUX_ctrl_out;

    HazardControlMUX hcMUX(
        .control_in(control_ctrl_out),
        .stall(stall),
        .control_out(hcMUX_ctrl_out)
    );

    // === REGISTER FILE ===
    // TODO: Instantiate RF
    logic [7:0] regFile_rs_val;
    logic [7:0] regFile_rd_val;
    logic cmp;

    RF regFile(
        .CLK(clk),
        .regWrite(memWb_ctrl_out.regWrite), // TODO: wire this
        .Rs(ifId_instr_out[5:3]),
        .Rd(ifId_instr_out[2:0]),
        .writeValue(write_value), // TODO: wire this
        .RsVal(regFile_rs_val),
        .RdVal(regFile_rd_val),
        .cmp(cmp)
    );

    logic branch_taken = cmp && control_ctrl_out.branch;
    logic flush = branch_taken;
    logic [2:0] branch_target = ifId_instr_out[2:0];


    // === HAZARD UNIT ===
    // TODO: Instantiate HazardUnit
    logic stall;
    HazardUnit hazardUnit(
        .ID_EX_MemRead(idEx_ctrl_out.memRead),
        .IF_ID_Rs(ifId_instr_out[5:3]),
        .IF_ID_Rd(ifId_instr_out[2:0]),
        .ID_EX_Rd(idEx_rd_out),
        .stall(stall)
    );

    // === ID/EX REGISTER ===
    // TODO: Instantiate ID/EX pipeline register
    logic [7:0] idEx_imm_in = {5'b0, ifId_instr_out[5:3]};
    ControlSignals idEx_ctrl_out;
    logic [7:0] idEx_rs_val_out, idEx_rd_val_out, idEx_imm_out;
    logic [2:0] idEx_rs_out, idEx_rd_out;

    ID_EX idExReg(
        .clk(clk),
        .reset(reset),
        .control_in(hcMUX_ctrl_out),
        .RsVal_in(regFile_rs_val),
        .RdVal_in(regFile_rd_val),
        .ImmVal_in(idEx_imm_in),
        .Rs_in(ifId_instr_out[5:3]),
        .Rd_in(ifId_instr_out[2:0]),
        .control_out(idEx_ctrl_out),
        .RsVal_out(idEx_rs_val_out),
        .RdVal_out(idEx_rd_val_out),
        .ImmVal_out(idEx_imm_out),
        .Rs_out(idEx_rs_out),
        .Rd_out(idEx_rd_out)
    );

    // === FORWARDING UNIT ===
    // TODO: Instantiate ForwardingUnit

    // === EX STAGE ===
    // TODO: Instantiate ALU and operand selection logic
    ForwardingMUX forwardA(
        .regVal(forwardA_regval),
        .memVal(forwardA_memval),
        .wbVal(forwardA_wbval),
        .forwardSel(forwardA_sel),
        .operandOut(forwardA_out)
    );
    
    ForwardingMUX forwardB(
        .regVal(forwardB_regval),
        .memVal(forwardB_memval),
        .wbVal(forwardB_wbval),
        .forwardSel(forwardB_sel),
        .operandOut(forwardB_out)
    );
    
    logic [7:0] alu_out;
    logic [1:0] alu_overflow;
    logic alu_zf;

    ALU alu(
        .OP(idEx_ctrl_out.OP),
        .R1(forwardA_out),
        .R2(forwardB_out),
        .OUT(alu_out),
        .OVERFLOW(alu_overflow),
        .ZF(alu_zf)
    );

    // === EX/MEM REGISTER ===
    // TODO: Instantiate EX/MEM pipeline register

    // === MEMORY STAGE ===
    // TODO: Instantiate data memory

    // === MEM/WB REGISTER ===
    // TODO: Instantiate MEM/WB pipeline register

    // === WB STAGE ===
    // TODO: Instantiate MemToRegMUX and connect to Register File write-back

endmodule
