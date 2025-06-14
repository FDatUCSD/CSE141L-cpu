// Top Level CPU Module

import Defs::*;
module TopLevel (
    input logic clk,
    input logic reset,
    input logic start,
    output logic done
);

    // ------------------------------------------FETCH-------------------------------------------- //
    logic [9:0] pc;
    logic cmp;
    logic branch_taken;
    logic flush;
    logic [8:0] ifId_instr_out;
    logic [2:0] branch_target;
    logic [7:0] regFile_rs_val;
    logic [7:0] regFile_rd_val;
    logic [8:0] instr;
    logic [9:0] ifId_pc_out;
    ControlSignals control_ctrl_out;
    ControlSignals hcMUX_ctrl_out;
    logic [7:0] write_value;
    logic stall;
    logic [7:0] idEx_imm_in;
    ControlSignals idEx_ctrl_out;
    logic [7:0] idEx_rs_val_out, idEx_rd_val_out, idEx_imm_out;
    logic [2:0] idEx_rs_out, idEx_rd_out;
    ForwardSel forwardA_sel, forwardB_sel;
    logic [7:0] forwardA_regval;
    logic [7:0] forwardB_regval;
    logic [7:0] exMem_alu_out;
    logic [7:0] forwardA_memval;
    logic [7:0] forwardB_memval;
    logic [7:0] forwardA_wbval;
    logic [7:0] forwardB_wbval;
    logic [7:0] forwardA_out, forwardB_out;
    logic [7:0] alu_out;
    logic [1:0] alu_overflow;
    logic alu_zf;
    ControlSignals exMem_ctrl_out;
    logic [7:0] exMem_rd_val_out;
    logic [2:0] exMem_rd_out;
    logic [7:0] mem_data_out;
    ControlSignals memWb_ctrl_out;
    logic [7:0] memWb_alu_out, memWb_mem_out;
    logic [2:0] memWb_rd_out;
    logic [7:0] exMem_imm_out;
    ForwardSel forwardBranch_sel;
    logic [7:0] forwardBranch_regval, forwardBranch_memval, forwardBranch_wbval;
    logic [7:0] forwardBranch_out, forwardMem_out;
    logic forwardMem_sel;
    logic [1:0] halt_delay_counter;
    logic halt_detected;
    logic [1:0] exp_error_detected;
    logic alu_exp_error;

    assign cmp = (forwardBranch_out == 8'b0);
    assign branch_taken = (cmp && control_ctrl_out.branch);
    assign flush = exp_error_detected || branch_taken;
    assign branch_target = ifId_instr_out[2:0];
    assign idEx_imm_in = {5'b0, ifId_instr_out[5:3]};
    assign forwardA_regval = idEx_rs_val_out;
    assign forwardB_regval = idEx_rd_val_out;
    assign forwardA_memval = exMem_alu_out;
    assign forwardB_memval = exMem_alu_out;
    assign forwardA_wbval = write_value;
    assign forwardB_wbval = write_value;
    assign forwardBranch_regval = regFile_rs_val;
    assign forwardBranch_memval = exMem_alu_out;
    assign forwardBranch_wbval = write_value;

    // always_ff @(posedge clk or posedge reset) begin
    //     if (reset) 
    //         done <= 1'b0;
    //     else if (halt_detected)
    //         done <= 1'b1;
    // end

    always_latch begin
        if (reset || start) begin
            done <= 0;
        end else if (ifId_instr_out == 9'b111000000) begin
            done <= 1;
        end
    end



    IF_module fetch (
        .Branch(branch_taken),
        .Target(branch_target),
        .Init(reset),
        .Stall(stall),
        .CLK(clk),
        .PC(pc),
        .done(done),
        .exp_error(exp_error_detected)
    );


    InstructionMemory instructionMem(
        .address(pc),
        .instruction(instr)
    );

    // === IF/ID REGISTER ===

    IF_ID ifIdReg(
        .CLK(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),
        .PC_in(pc),
        .instr_in(instr),
        .PC_out(ifId_pc_out),
        .instr_out(ifId_instr_out)
    );

    // ---------------------------------------DECODE--------------------------------------//

    // === HALT DETECTOR ===
    // HaltDetector haltDetector(
    //     .instr_in(ifId_instr_out),
    //     .halt_detected(halt_detected)
    // );


    Control control(
        .init(reset),
        .instruction(ifId_instr_out),
        .ctrl(control_ctrl_out)
    );

    ExceptionDetector exceptionDetector(
        .opcode(idEx_ctrl_out.OP),
        .rs(idEx_rs_out),
        .rd(idEx_rd_out),
        .exp_error_in(exMem_exp_error_out),
        .rsVal(regFile_rs_val),
        .exception_detected(exp_error_detected)
    );


    HazardControlMUX hcMUX(
        .control_in(control_ctrl_out),
        .stall(stall),
        .control_out(hcMUX_ctrl_out)
    );



    RF regFile(
        .CLK(clk),
        .regWrite(memWb_ctrl_out.regWrite),
        .Rs(ifId_instr_out[5:3]),
        .Rd(ifId_instr_out[2:0]),
        .writeValue(write_value),
        .RsVal(regFile_rs_val),
        .RdVal(regFile_rd_val),
        .writeAddr(memWb_rd_out),
        .reset(reset)
    );

    HazardUnit hazardUnit(
        .ID_EX_MemRead(idEx_ctrl_out.memRead),
        .IF_ID_Rs(ifId_instr_out[5:3]),
        .IF_ID_Rd(ifId_instr_out[2:0]),
        .ID_EX_Rd(idEx_rd_out),
        .stall(stall)
    );


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
    ForwardingUnit fwdUnit(
        .EX_Rs(idEx_rs_out),
        .EX_Rd(idEx_rd_out),
        .MEM_Rd(exMem_rd_out),
        .WB_Rd(memWb_rd_out),
        .Branch_Rs(ifId_instr_out[5:3]),
        .MEM_RegWrite(exMem_ctrl_out.regWrite),
        .WB_RegWrite(memWb_ctrl_out.regWrite),
        .ForwardA(forwardA_sel),
        .ForwardB(forwardB_sel),
        .ForwardBranch(forwardBranch_sel),
        .ForwardMem(forwardMem_sel)
    );


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

    ForwardingMUX branchMux(
        .regVal(forwardBranch_regval),
        .memVal(forwardBranch_memval),
        .wbVal(forwardBranch_wbval),
        .forwardSel(forwardBranch_sel),
        .operandOut(forwardBranch_out)
    );


    ALU alu(
        .OP(idEx_ctrl_out.OP),
        .R1(forwardA_out),
        .R2(forwardB_out),
        .OUT(alu_out),
        .OVERFLOW(alu_overflow),
        .ZF(alu_zf),
        .exp_error(alu_exp_error)
    );

    // === EX/MEM REGISTER ===

    EX_MEM exMemReg(
        .clk(clk),
        .reset(reset),
        .control_in(idEx_ctrl_out),
        .ALUResult_in(alu_out),
        .RdVal_in(forwardB_out),
        .Rd_in(idEx_rd_out),
        .ImmVal_in(idEx_imm_out),
        .control_out(exMem_ctrl_out),
        .ALUResult_out(exMem_alu_out),
        .RdVal_out(exMem_rd_val_out),
        .Rd_out(exMem_rd_out),
        .ImmVal_out(exMem_imm_out),
        .exp_error_in(alu_exp_error),
        .exp_error_out(exMem_exp_error_out)
    );

    // === MEMORY STAGE ===
    DataMemMUX dataMemMux(
        .sel(forwardMem_sel),
        .exMem_data(exMem_rd_val_out),
        .wb_data(write_value),
        .data_out(forwardMem_out)
    );
    DataMemory data_mem1(
        .clk(clk),
        .memWrite(exMem_ctrl_out.memWrite), // should write or not
        .memRead(exMem_ctrl_out.memRead), // should read or not
        .address(exMem_imm_out), // address to read or write to
        .writeData(forwardMem_out), // the data to write
        .readData(mem_data_out) // the output
    );

    // === MEM/WB REGISTER ===

    MEM_WB memWbReg(
        .clk(clk),
        .reset(reset),
        .control_in(exMem_ctrl_out),
        .ALUResult_in(exMem_alu_out),
        .memData_in(mem_data_out),
        .Rd_in(exMem_rd_out),
        .control_out(memWb_ctrl_out),
        .ALUResult_out(memWb_alu_out),
        .memData_out(memWb_mem_out),
        .Rd_out(memWb_rd_out)
    );

    // === WB STAGE ===
    MemToRegMUX memToRegMux(
        .aluResult(memWb_alu_out),
        .memResult(memWb_mem_out),
        .sel(memWb_ctrl_out.MemToReg),
        .out(write_value)
    );

endmodule
