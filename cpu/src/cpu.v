`timescale 1ns / 1ps
module cpu(
    input wire clock,
    input wire reset,
    input wire[31:0] CPURomData,
    input wire CPUBusResponse,
    input wire CPUBusReady,
    input wire CPUSerialInterrupt,
    output reg[31:0] CPUAddress,
    output reg CPUWriteEnable,
    output reg CPUDataSize,
    output reg[31:0] CPUWriteData
);
    wire[31:0] PCPlus4;//pc -> control
    wire[31:0] PC;//pc -> if_id
    wire PCTLBMissOut;//pc -> if_id
    wire IfNextInstructionInDelaySlotOut;//id -> if_id
    wire[31:0] IdPC;//if_id -> id
    wire[31:0] IdInstruction;//if_id -> id
    wire IdPCTLBMiss;//if_id -> id
    wire IdIsInDelaySlot;//if_id -> id
    wire RegisterReadEnable1;//id -> reg
    wire RegisterReadEnable2;//id -> reg
    wire[4:0] RegisterAddress1;//id -> reg
    wire[4:0] RegisterAddress2;//id -> reg
    wire[4:0] CPAddress;//id -> cp0
    wire[31:0] RegisterData1;//reg -> id
    wire[31:0] RegisterData2;//reg -> id
    wire[31:0] CPData;//cp0 -> id
    wire[31:0] hi;//hilo -> id
    wire[31:0] lo;//hilo -> id
    wire[31:0] IdPCOut;//id -> id_ex
    wire[4:0] IdWriteCPAddressOut;//id -> id_ex
    wire[7:0] IdALUOperationOut;//id -> id_ex
    wire[2:0] IdALUSelOut;//id -> id_ex
    wire[31:0] IdRegister1Out;//id -> id_ex
    wire[31:0] IdRegister2Out;//id -> id_ex
    wire IdWriteRegisterOut;//id -> id_ex
    wire[4:0] IdWriteAddressOut;//id -> id_ex
    wire IdIsInDelaySlotOut;//id -> id_ex
    wire[31:0] IdLinkAddressOut;//id -> id_ex
    wire IdWriteHiOut;//id -> id_ex
    wire IdWriteLoOut;//id -> id_ex
    wire[15:0] IdInstructionOut;//id -> id_ex
    wire Idtlbwi;//id -> id_ex
    wire Idsyscall;//id -> id_ex
    wire Ideret;//id -> id_ex
    wire Idprivilege;//id -> id_ex
    wire IdValidInstruction;//id -> id_ex
    wire IdPCTLBMissOut;//id -> id_ex
    wire BranchFlag;//id -> pc / control
    wire[31:0] BranchTarget;//id -> pc / control
    wire[31:0] ExLinkAddress;//id_ex -> ex
    wire ExIsInDelaySlot;//id_ex -> ex
    wire[7:0] ExALUOperation;//id_ex -> ex
    wire[2:0] ExALUSel;//id_ex -> ex
    wire[31:0] ExRegister1;//id_ex -> ex
    wire[31:0] ExRegister2;//id_ex -> ex
    wire ExWriteRegister;//id_ex -> ex
    wire[4:0] ExWriteAddress;//id_ex -> ex
    wire ExWriteHi;//id_ex -> ex
    wire ExWriteLo;//id_ex -> ex
    wire[4:0] ExWriteCPAddress;//id_ex ->ex
    wire[15:0] ExInstruction;//id_ex -> ex
    wire Extlbwi;//id_ex -> ex
    wire Exsyscall;//id_ex -> ex
    wire Exeret;//id_ex -> ex
    wire Exprivilege;//id_ex -> ex
    wire ExValidInstruction;//id_ex -> ex
    wire ExPCTLBMiss;//id_ex -> ex
    wire[31:0] ExPC;//id_ex -> ex
    wire ExIsInDelaySlotOut;//ex -> ex_mem
    wire ExWriterRegisterOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire[4:0] ExWriteAddressOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire[31:0] ExWriteDataOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire[31:0] ExWriteHiDataOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire ExWriteHiOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire[31:0] ExWriteLoDataOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire ExWriteLoOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire ExWriteCPOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire[4:0] ExWriteCPAddressOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire[31:0] ExWriteCPDataOut;//ex -> ex_mem / id(data dependecy between ex and id)
    wire ExSignExtend;//ex -> ex_mem
    wire ExtlbwiOut;//ex -> ex_mem
    wire ExsyscallOut;//ex -> ex_mem
    wire ExeretOut;//ex -> ex_mem
    wire ExprivilegeOut;//ex -> ex_mem
    wire[31:0] ExPCOut;//ex -> ex_mem
    wire ExValidInstructionOut;//ex -> ex_mem
    wire ExReadTLBMiss;//control -> ex_mem
    wire ExWriteTLBMiss;//control -> ex_mem
    wire ExReadError;//control -> ex_mem
    wire ExWriteError;//control -> ex_mem
    wire ExPCTLBMissOut;//ex -> ex_mem
    wire ExAddressReadPrivilege;//ex -> ex_mem
    wire ExAddressWritePrivilege;//ex -> ex_mem
    wire[31:0] RAMAddress;//ex -> control
    wire[31:0] RAMData;//ex -> control
    wire RAMReadEnable;//ex -> control / ex_mem
    wire RAMWriteEnable;//ex -> control
    wire RAMDataSize;//ex -> control
    wire ExIsLoad;//ex -> id
    wire MemWriteRegister;//ex_mem -> mem
    wire[4:0] MemWriteAddress;//ex_mem -> mem
    wire[31:0] MemWriteData;//ex_mem -> mem
    wire[31:0] MemWriteHiData;//ex_mem -> mem
    wire[31:0] MemWriteLoData;//ex_mem -> mem
    wire MemWriteHi;//ex_mem -> mem
    wire MemWriteLo;//ex_mem -> mem
    wire MemSignExtend;//ex_mem -> mem
    wire MemRAMReadEnable;//ex_mem -> mem
    wire MemWriteCP;//ex_mem -> mem
    wire[4:0] MemWriteCPAddress;//ex_mem -> mem
    wire[31:0] MemWriteCPData;//ex_mem -> mem
    wire Memtlbwi;//ex_mem -> tlb
    wire Memsyscall;//ex_mem -> control
    wire Memeret;//ex_mem -> control
    wire MemValidInstruction;//ex_mem -> control
    wire Memprivilege;//ex_mem -> control
    wire MemTLBMissRead;//ex_mem -> control
    wire MemTLBMissWrite;//ex_mem -> control
    wire MemReadError;//ex_mem -> control
    wire MemWriteError;//ex_mem -> control
    wire MemIsInDelaySlot;//ex_mem -> control
    wire[31:0] MemPC;//ex_mem -> control
    wire MemAddressReadPrivilege;//ex_mem -> control
    wire MemAddressWritePrivilege;//ex_mem -> control
    wire[31:0] MemBadAddress;//ex_mem -> control
    wire MemWriteRegisterOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire[4:0] MemWriteAddressOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire[31:0] MemWriteDataOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire[31:0] MemHiOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire[31:0] MemLoOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire MemWriteHiOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire MemWriteLoOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire MemWriteCPOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire[4:0] MemWriteCPAddressOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire[31:0] MemWriteCPDataOut;//mem -> mem_wb / id(data dependecy between mem and id)
    wire WbWriteRegister;//mem_wb -> reg
    wire[4:0] WbWriteAddress;//mem_wb -> reg
    wire[31:0] WbWriteData;//mem_wb -> reg
    wire[31:0] WbHi;//mem_wb -> hilo
    wire[31:0] WbLo;//mem_wb -> hilo
    wire WbWriteHi;//mem_wb -> hilo
    wire WbWriteLo;//mem_wb -> hilo
    wire WbWrite0;//mem_wb -> cp
    wire WbWrite2;//mem_wb -> cp
    wire WbWrite3;//mem_wb -> cp
    wire WbWrite8;//mem_wb -> cp
    wire WbWrite10;//mem_wb -> cp
    wire WbWrite11;//mem_wb -> cp
    wire WbWrite12;//mem_wb -> cp
    wire WbWrite13;//mem_wb -> cp
    wire WbWrite14;//mem_wb -> cp
    wire WbWrite15;//mem_wb -> cp
    wire WbWrite18;//mem_wb -> cp
    wire WbWrite19;//mem_wb -> cp
    wire[31:0] WbWrite0Data;//mem_wb -> cp
    wire[31:0] WbWrite2Data;//mem_wb -> cp
    wire[31:0] WbWrite3Data;//mem_wb -> cp
    wire[31:0] WbWrite8Data;//mem_wb -> cp
    wire[31:0] WbWrite10Data;//mem_wb -> cp
    wire[31:0] WbWrite11Data;//mem_wb -> cp
    wire[31:0] WbWrite12Data;//mem_wb -> cp
    wire[31:0] WbWrite13Data;//mem_wb -> cp
    wire[31:0] WbWrite14Data;//mem_wb -> cp
    wire[31:0] WbWrite15Data;//mem_wb -> cp
    wire[31:0] WbWrite18Data;//mem_wb -> cp
    wire[31:0] WbWrite19Data;//mem_wb -> cp
    wire[31:0] index0Out;//cp -> control / tlb
    wire[31:0] entryLo02Out;//cp -> control / tlb
    wire[31:0] entryLo13Out;//cp -> control / tlb
    wire[31:0] entryHi10Out;//cp -> control / tlb
    wire[31:0] status12Out;//cp -> control
    wire[31:0] cause13Out;//cp -> control
    wire[31:0] epc14Out;//cp -> control
    wire[31:0] ebase15Out;//cp -> control
    wire[31:0] watchLo18Out;//cp -> control
    wire[31:0] watchHi19Out;//cp -> control
    wire clockInterrupt;//cp0 -> control
    wire PauseRequest;//id -> control
    wire PauseSignal;//control -> pc / if_id / id / id_ex
    wire[31:0] Address;//control
    wire WriteEnable;//control
    wire DataSize;//control
    wire[31:0] WriteData;//control
    wire[31:0] InstructionResult;//control -> if_id
    wire[31:0] LoadResult;//control -> mem
    wire ValidAddress;//tlb -> control
    wire isMiss;//tlb -> control
    wire[31:0] TLBVirtualAddress;//control -> tlb
    wire[31:0] TLBPhysicalAddress;//tlb -> control
    wire TLBWriteEnable;//control -> tlb
    wire ExValidAddress;//control -> ex_mem
    wire ExIsMiss;//control -> ex_mem
    wire PCTLBMiss;//control -> pc
    wire MemWriteepc;//control -> ex_mem
    wire[31:0] MemWriteepcData;//control -> ex_mem
    wire MemWritestatus;//control -> ex_mem
    wire[31:0] MemWritestatusData;//control -> ex_mem
    wire MemWritecause;//control -> ex_mem
    wire[31:0] MemWritecauseData;//control -> ex_mem
    wire MemWritebadaddr;//control -> ex_mem
    wire[31:0] MemWritebadaddrData;//control -> ex_mem
    wire flush;//control -> all
    wire[31:0] flushTarget;//control -> all
    PCRegister PCRegister0(
        .clock(clock),
        .reset(reset),
        .ready(CPUBusReady),
        .PauseSignal(PauseSignal),
        .BranchFlag(BranchFlag),
        .BranchTarget(BranchTarget),
        .PCTLBMiss(PCTLBMiss),
        .flush(flush),
        .flushTarget(flushTarget),
        .PC(PC),
        .PCPlus4(PCPlus4),
        .PCTLBMissOut(PCTLBMissOut)
    );
    if_id if_id0(
        .clock(clock),
        .reset(reset),
        .flush(flush),
        .flushTarget(flushTarget),
        .ready(CPUBusReady),
        .PauseSignal(PauseSignal),
        .PC(PC),
        .Instruction(InstructionResult),
        .PCTLBMiss(PCTLBMissOut),
        .IsInDelaySlot(IfNextInstructionInDelaySlotOut),
        .IdPC(IdPC),
        .IdInstruction(IdInstruction),
        .PCTLBMissOut(IdPCTLBMiss),
        .IsInDelaySlotOut(IdIsInDelaySlot)
    );
    id id0(
        .reset(reset),
        .IdPC(IdPC),
        .IdInstruction(IdInstruction),
        .RegisterData1(RegisterData1),
        .RegisterData2(RegisterData2),
        .CPData(CPData),
        .IsInDelaySlotIn(IdIsInDelaySlot),
        .hi(hi),
        .lo(lo),
        .ExWriteRegisterIn(ExWriterRegisterOut),
        .ExWriteDataIn(ExWriteDataOut),
        .ExWriteAddressIn(ExWriteAddressOut),
        .ExWriteHiIn(ExWriteHiOut),
        .ExWriteHiDataIn(ExWriteHiDataOut),
        .ExWriteLoIn(ExWriteLoOut),
        .ExWriteLoDataIn(ExWriteLoDataOut),
        .ExWriteCPIn(ExWriteCPOut),
        .ExWriteCPAddress(ExWriteCPAddressOut),
        .ExWriteCPData(ExWriteCPDataOut),
        .MemWriteRegisterIn(MemWriteRegisterOut),
        .MemWriteDataIn(MemWriteDataOut),
        .MemWriteAddressIn(MemWriteAddressOut),
        .MemWriteHiIn(MemWriteHiOut),
        .MemWriteHiDataIn(MemHiOut),
        .MemWriteLoIn(MemWriteLoOut),
        .MemWriteLoDataIn(MemLoOut),
        .MemWriteCPIn(MemWriteCPOut),
        .MemWriteCPAddress(MemWriteCPAddressOut),
        .MemWriteCPData(MemWriteCPDataOut),
        .ExIsLoad(ExIsLoad),
        .PCTLBMiss(IdPCTLBMiss),
        .currentPC(IdPCOut),
        .tlbwi(Idtlbwi),
        .syscall(Idsyscall),
        .eret(Ideret),
        .privilege(Idprivilege),
        .ValidInstruction(IdValidInstruction),
        .RegisterReadEnable1(RegisterReadEnable1),
        .RegisterReadEnable2(RegisterReadEnable2),
        .RegisterAddress1(RegisterAddress1),
        .RegisterAddress2(RegisterAddress2),
        .CPAddress(CPAddress),
        .WriteCPAddress(IdWriteCPAddressOut),
        .ALUOperation(IdALUOperationOut),
        .ALUSel(IdALUSelOut),
        .Register1(IdRegister1Out),
        .Register2(IdRegister2Out),
        .WriteAddressOut(IdWriteAddressOut),
        .WriteRegisterOut(IdWriteRegisterOut),
        .WriteHiOut(IdWriteHiOut),
        .WriteLoOut(IdWriteLoOut),
        .NextInstructionInDelaySlot(IfNextInstructionInDelaySlotOut),
        .BranchFlag(BranchFlag),
        .BranchTarget(BranchTarget),
        .LinkAddress(IdLinkAddressOut),
        .PauseRequest(PauseRequest),
        .IdInstructionOut(IdInstructionOut),
        .IsInDelaySlotOut(IdIsInDelaySlotOut),
        .PCTLBMissOut(IdPCTLBMissOut)
    );
    hilo_reg hilo_reg0(
        .clock(clock),
        .reset(reset),
        .ready(CPUBusReady),
        .WriteHiEnable(WbWriteHi),
        .WriteLoEnable(WbWriteLo),
        .HiIn(WbHi),
        .LoIn(WbLo),
        .HiOut(hi),
        .LoOut(lo)
    );
    regfile regfile0(
        .clock(clock),
        .reset(reset),
        .ready(CPUBusReady),
        .WriteEnable(WbWriteRegister),
        .WriteAddress(WbWriteAddress),
        .WriteData(WbWriteData),
        .ReadEnable1(RegisterReadEnable1),
        .ReadAddress1(RegisterAddress1),
        .ReadData1(RegisterData1),
        .ReadEnable2(RegisterReadEnable2),
        .ReadAddress2(RegisterAddress2),
        .ReadData2(RegisterData2)
    );
    cp cp0(
        .clock(clock),
        .reset(reset),
        .ready(CPUBusReady),
        .address(CPAddress),
        .write0(WbWrite0),
        .write2(WbWrite2),
        .write3(WbWrite3),
        .write8(WbWrite8),
        .write10(WbWrite10),
        .write11(WbWrite11),
        .write12(WbWrite12),
        .write13(WbWrite13),
        .write14(WbWrite14),
        .write15(WbWrite15),
        .write18(WbWrite18),
        .write19(WbWrite19),
        .write0data(WbWrite0Data),
        .write2data(WbWrite2Data),
        .write3data(WbWrite3Data),
        .write8data(WbWrite8Data),
        .write10data(WbWrite10Data),
        .write11data(WbWrite11Data),
        .write12data(WbWrite12Data),
        .write13data(WbWrite13Data),
        .write14data(WbWrite14Data),
        .write15data(WbWrite15Data),
        .write18data(WbWrite18Data),
        .write19data(WbWrite19Data),
        .clockInterrupt(clockInterrupt),
        .value(CPData),
        .index0Out(index0Out),
        .entryLo02Out(entryLo02Out),
        .entryLo13Out(entryLo13Out),
        .entryHi10Out(entryHi10Out),
        .status12Out(status12Out),
        .cause13Out(cause13Out),
        .epc14Out(epc14Out),
        .ebase15Out(ebase15Out),
        .watchLo18Out(watchLo18Out),
        .watchHi19Out(watchHi19Out)
    );
    id_ex id_ex0(
        .clock(clock),
        .reset(reset),
        .ready(CPUBusReady),
        .flush(flush),
        .flushTarget(flushTarget),
        .PauseSignal(PauseSignal),
        .IdALUOperation(IdALUOperationOut),
        .IdALUSel(IdALUSelOut),
        .IdRegister1(IdRegister1Out),
        .IdRegister2(IdRegister2Out),
        .IdWriteAddress(IdWriteAddressOut),
        .IdWriteRegister(IdWriteRegisterOut),
        .IdWriteHi(IdWriteHiOut),
        .IdWriteLo(IdWriteLoOut),
        .IdWriteCPAddress(IdWriteCPAddressOut),
        .IdLinkAddress(IdLinkAddressOut),
        .IdIsInDelaySlot(IdIsInDelaySlotOut),
        .Idtlbwi(Idtlbwi),
        .Idsyscall(Idsyscall),
        .Ideret(Ideret),
        .Idprivilege(Idprivilege),
        .IdValidInstruction(IdValidInstruction),
        .IdInstruction(IdInstructionOut),
        .PCTLBMiss(IdPCTLBMissOut),
        .IdPC(IdPCOut),
        .ExALUOperation(ExALUOperation),
        .ExALUSel(ExALUSel),
        .ExRegister1(ExRegister1),
        .ExRegister2(ExRegister2),
        .ExWriteAddress(ExWriteAddress),
        .ExWriteRegister(ExWriteRegister),
        .ExWriteHi(ExWriteHi),
        .ExWriteLo(ExWriteLo),
        .ExWriteCPAddress(ExWriteCPAddress),
        .ExLinkAddress(ExLinkAddress),
        .ExIsInDelaySlot(ExIsInDelaySlot),
        .Extlbwi(Extlbwi),
        .Exsyscall(Exsyscall),
        .Exeret(Exeret),
        .Exprivilege(Exprivilege),
        .ExValidInstruction(ExValidInstruction),
        .ExInstruction(ExInstruction),
        .PCTLBMissOut(ExPCTLBMiss),
        .ExPC(ExPC)
    );
    ex ex0(
        .reset(reset),
        .ALUOperation(ExALUOperation),
        .ALUSel(ExALUSel),
        .Register1(ExRegister1),
        .Register2(ExRegister2),
        .WriteAddressIn(ExWriteAddress),
        .WriteRegisterIn(ExWriteRegister),
        .WriteHiIn(ExWriteHi),
        .WriteLoIn(ExWriteLo),
        .LinkAddress(ExLinkAddress),
        .IsInDelaySlotIn(ExIsInDelaySlot),
        .Instruction(ExInstruction),
        .WriteCPAddress(ExWriteCPAddress),
        .tlbwi(Extlbwi),
        .syscall(Exsyscall),
        .eret(Exeret),
        .privilege(Exprivilege),
        .ValidInstruction(ExValidInstruction),
        .PCTLBMiss(ExPCTLBMiss),
        .currentPC(ExPC),
        .WriteDataOut(ExWriteDataOut),
        .WriteAddressOut(ExWriteAddressOut),
        .WriteRegisterOut(ExWriterRegisterOut),
        .WriteHiDataOut(ExWriteHiDataOut),
        .WriteHiOut(ExWriteHiOut),
        .WriteLoDataOut(ExWriteLoDataOut),
        .WriteLoOut(ExWriteLoOut),
        .IsLoad(ExIsLoad),
        .SignExtend(ExSignExtend),
        .RAMAddress(RAMAddress),
        .RAMWriteEnable(RAMWriteEnable),
        .RAMData(RAMData),
        .RAMDataSize(RAMDataSize),
        .RAMReadEnable(RAMReadEnable),
        .WriteCPOut(ExWriteCPOut),
        .WriteCPAddressOut(ExWriteCPAddressOut),
        .WriteCPDataOut(ExWriteCPDataOut),
        .IsInDelaySlotOut(ExIsInDelaySlotOut),
        .tlbwiOut(ExtlbwiOut),
        .syscallOut(ExsyscallOut),
        .eretOut(ExeretOut),
        .privilegeOut(ExprivilegeOut),
        .ValidInstructionOut(ExValidInstructionOut),
        .PCTLBMissOut(ExPCTLBMissOut),
        .currentPCOut(ExPCOut),
        .ExAddressReadPrivilege(ExAddressReadPrivilege),
        .ExAddressWritePrivilege(ExAddressWritePrivilege)
    );
    ex_mem ex_mem0(
        .clock(clock),
        .reset(reset),
        .ready(CPUBusReady),
        .flush(flush),
        .flushTarget(flushTarget),
        .ExWriteAddress(ExWriteAddressOut),
        .ExWriteRegister(ExWriterRegisterOut),
        .ExWriteData(ExWriteDataOut),
        .ExWriteHiData(ExWriteHiDataOut),
        .ExWriteLoData(ExWriteLoDataOut),
        .ExWriteHi(ExWriteHiOut),
        .ExWriteLo(ExWriteLoOut),
        .ExIsInDelaySlot(ExIsInDelaySlotOut),
        .ExSignExtend(ExSignExtend),
        .ExRAMReadEnable(RAMReadEnable),
        .ExWriteCP(ExWriteCPOut),
        .ExWriteCPAddress(ExWriteCPAddressOut),
        .ExWriteCPData(ExWriteCPDataOut),
        .Extlbwi(ExtlbwiOut),
        .Exsyscall(ExsyscallOut),
        .Exeret(ExeretOut),
        .Exprivilege(ExprivilegeOut),
        .ExValidInstruction(ExValidInstructionOut),
        .PCTLBMiss(ExPCTLBMissOut),
        .ExReadTLBMiss(ExReadTLBMiss),
        .ExWriteTLBMiss(ExWriteTLBMiss),
        .ExReadError(ExReadError),
        .ExWriteError(ExWriteError),
        .ExPC(ExPCOut),
        .ExAddressReadPrivilege(ExAddressReadPrivilege),
        .ExAddressWritePrivilege(ExAddressWritePrivilege),
        .ExBadAddress(RAMAddress),
        .MemWriteAddress(MemWriteAddress),
        .MemWriteRegister(MemWriteRegister),
        .MemWriteData(MemWriteData),
        .MemWriteHiData(MemWriteHiData),
        .MemWriteLoData(MemWriteLoData),
        .MemWriteHi(MemWriteHi),
        .MemWriteLo(MemWriteLo),
        .MemIsInDelaySlot(MemIsInDelaySlot),
        .MemSignExtend(MemSignExtend),
        .MemRAMReadEnable(MemRAMReadEnable),
        .MemWriteCP(MemWriteCP),
        .MemWriteCPAddress(MemWriteCPAddress),
        .MemWriteCPData(MemWriteCPData),
        .Memtlbwi(Memtlbwi),
        .Memsyscall(Memsyscall),
        .Memeret(Memeret),
        .Memprivilege(Memprivilege),
        .TLBMissRead(MemTLBMissRead),
        .TLBMissWrite(MemTLBMissWrite),
        .ReadError(MemReadError),
        .WriteError(MemWriteError),
        .MemValidInstruction(MemValidInstruction),
        .MemPC(MemPC),
        .MemAddressReadPrivilege(MemAddressReadPrivilege),
        .MemAddressWritePrivilege(MemAddressWritePrivilege),
        .MemBadAddress(MemBadAddress)
    );
    mem mem0(
        .reset(reset),
        .WriteAddressIn(MemWriteAddress),
        .WriteRegisterIn(MemWriteRegister),
        .WriteDataIn(MemWriteData),
        .HiIn(MemWriteHiData),
        .LoIn(MemWriteLoData),
        .WriteHiIn(MemWriteHi),
        .WriteLoIn(MemWriteLo),
        .SignExtend(MemSignExtend),
        .RAMReadEnable(MemRAMReadEnable),
        .RAMData(LoadResult),
        .WriteCP(MemWriteCP),
        .WriteCPAddress(MemWriteCPAddress),
        .WriteCPData(MemWriteCPData),
        .WriteAddressOut(MemWriteAddressOut),
        .WriteRegisterOut(MemWriteRegisterOut),
        .WriteDataOut(MemWriteDataOut),
        .HiOut(MemHiOut),
        .LoOut(MemLoOut),
        .WriteHiOut(MemWriteHiOut),
        .WriteLoOut(MemWriteLoOut),
        .WriteCPOut(MemWriteCPOut),
        .WriteCPAddressOut(MemWriteCPAddressOut),
        .WriteCPDataOut(MemWriteCPDataOut)
    );
    mem_wb mem_wb0(
        .clock(clock),
        .reset(reset),
        .ready(CPUBusReady),
        .flush(flush),
        .MemWriteAddress(MemWriteAddressOut),
        .MemWriteRegister(MemWriteRegisterOut),
        .MemWriteData(MemWriteDataOut),
        .MemHi(MemHiOut),
        .MemLo(MemLoOut),
        .MemWriteHi(MemWriteHiOut),
        .MemWriteLo(MemWriteLoOut),
        .MemWriteCP(MemWriteCPOut),
        .MemWriteCPAddress(MemWriteCPAddressOut),
        .MemWriteCPData(MemWriteCPDataOut),
        .MemWriteepc(MemWriteepc),
        .MemWriteepcData(MemWriteepcData),
        .MemWritestatus(MemWritestatus),
        .MemWritestatusData(MemWritestatusData),
        .MemWritecause(MemWritecause),
        .MemWritecauseData(MemWritecauseData),
        .MemWritebadaddr(MemWritebadaddr),
        .MemWritebadaddrData(MemWritebadaddrData),
        .WbWriteAddress(WbWriteAddress),
        .WbWriteRegister(WbWriteRegister),
        .WbWriteData(WbWriteData),
        .WbHi(WbHi),
        .WbLo(WbLo),
        .WbWriteHiOut(WbWriteHi),
        .WbWriteLoOut(WbWriteLo),
        .Write0(WbWrite0),
        .Write2(WbWrite2),
        .Write3(WbWrite3),
        .Write8(WbWrite8),
        .Write10(WbWrite10),
        .Write11(WbWrite11),
        .Write12(WbWrite12),
        .Write13(WbWrite13),
        .Write14(WbWrite14),
        .Write15(WbWrite15),
        .Write18(WbWrite18),
        .Write19(WbWrite19),
        .Write0Data(WbWrite0Data),
        .Write2Data(WbWrite2Data),
        .Write3Data(WbWrite3Data),
        .Write8Data(WbWrite8Data),
        .Write10Data(WbWrite10Data),
        .Write11Data(WbWrite11Data),
        .Write12Data(WbWrite12Data),
        .Write13Data(WbWrite13Data),
        .Write14Data(WbWrite14Data),
        .Write15Data(WbWrite15Data),
        .Write18Data(WbWrite18Data),
        .Write19Data(WbWrite19Data)
    );
    control control0(
        .reset(reset),
        .clock(clock),
        .ready(CPUBusReady),
        .flushin(flush),
        .Response(CPUBusResponse),
        .SerialInterrupt(CPUSerialInterrupt),
        .clockInterrupt(clockInterrupt),
        .BranchFlag(BranchFlag),
        .BranchTarget(BranchTarget),
        .PCPlus4(PCPlus4),
        .PauseRequest(PauseRequest),
        .RAMAddress(RAMAddress),
        .RAMWriteEnable(RAMWriteEnable),
        .RAMData(RAMData),
        .RAMDataSize(RAMDataSize),
        .RAMReadEnable(RAMReadEnable),
        .ReadResult(CPURomData),
        .TLBPhysicalAddress(TLBPhysicalAddress),
        .ValidAddress(ValidAddress),
        .isMiss(isMiss),
        .currentPC(MemPC),
        .isInDelaySlot(MemIsInDelaySlot),
        .excBadAddress(MemBadAddress),
        .cp0status(status12Out),
        .cp0cause(cause13Out),
        .cp0epc(epc14Out),
        .cp0base(ebase15Out),
        .cp0watchLo(watchLo18Out),
        .cp0watchHi(watchHi19Out),
        .TLBMissRead(MemTLBMissRead),
        .TLBMissWrite(MemTLBMissWrite),
        .ReadError(MemReadError),
        .WriteError(MemWriteError),
        .ValidInstruction(MemValidInstruction),
        .syscall(Memsyscall),
        .InstructionPrivilege(Memprivilege),
        .AddressReadPrivilege(MemAddressReadPrivilege),
        .AddressWritePrivilege(MemAddressWritePrivilege),
        .eret(Memeret),
        .Writeepc(MemWriteepc),
        .WriteepcData(MemWriteepcData),
        .Writestatus(MemWritestatus),
        .WritestatusData(MemWritestatusData),
        .Writecause(MemWritecause),
        .WritecauseData(MemWritecauseData),
        .Writebadaddr(MemWritebadaddr),
        .WritebadaddrData(MemWritebadaddrData),
        .flush(flush),
        .targetAddress(flushTarget),
        .TLBVirtualAddress(TLBVirtualAddress),
        .TLBWriteEnable(TLBWriteEnable),
        .Address(Address),
        .WriteEnable(WriteEnable),
        .DataSize(DataSize),
        .WriteData(WriteData),
        .PauseSignal(PauseSignal),
        .ExReadTLBMiss(ExReadTLBMiss),
        .ExWriteTLBMiss(ExWriteTLBMiss),
        .ExReadError(ExReadError),
        .ExWriteError(ExWriteError),
        .PCReadTLBMiss(PCTLBMiss),
        .InstructionResult(InstructionResult),
        .LoadResult(LoadResult)
    );
    tlb tlb0(
        .clock(clock),
        .reset(reset),
        .VirtualAddress(TLBVirtualAddress),
        .WriteEnable(TLBWriteEnable),
        .WriteTLB(Memtlbwi),
        .index(index0Out),
        .entryLo0(entryLo02Out),
        .entryLo1(entryLo13Out),
        .entryHi(entryHi10Out),
        .ValidAddress(ValidAddress),
        .isMiss(isMiss),
        .PhysicalAddress(TLBPhysicalAddress)
    );
    always @(*) begin
        CPUAddress <= Address;
        CPUWriteEnable <= WriteEnable;
        CPUDataSize <= DataSize;
        CPUWriteData <= WriteData;
    end
endmodule