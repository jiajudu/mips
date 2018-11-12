`timescale 1ns / 1ps
module control(
    input wire reset,
    input wire clock,
    input wire ready,
    input wire flushin,
    input wire Response,
    input wire SerialInterrupt,
    input wire clockInterrupt,
    input wire BranchFlag,
    input wire[31:0] BranchTarget,
    input wire[31:0] PCPlus4,
    input wire PauseRequest,
    input wire[31:0] RAMAddress,
    input wire RAMWriteEnable,
    input wire[31:0] RAMData,
    input wire RAMDataSize,
    input wire RAMReadEnable,
    input wire[31:0] ReadResult,
    input wire[31:0] TLBPhysicalAddress,
    input wire ValidAddress,
    input wire isMiss,
    input wire[31:0] currentPC,
    input wire isInDelaySlot,
    input wire[31:0] excBadAddress,
    input wire[31:0] cp0status,
    input wire[31:0] cp0cause,
    input wire[31:0] cp0epc,
    input wire[31:0] cp0base,
    input wire[31:0] cp0watchLo,
    input wire[31:0] cp0watchHi,
    input wire TLBMissRead,
    input wire TLBMissWrite,
    input wire ReadError,
    input wire WriteError,
    input wire ValidInstruction,
    input wire syscall,
    input wire InstructionPrivilege,
    input wire AddressReadPrivilege,
    input wire AddressWritePrivilege,
    input wire eret,
    output reg Writeepc,
    output reg[31:0] WriteepcData,
    output reg Writestatus,
    output reg[31:0] WritestatusData,
    output reg Writecause,
    output reg[31:0] WritecauseData,
    output reg Writebadaddr,
    output reg[31:0] WritebadaddrData,
    output reg flush,
    output reg[31:0] targetAddress,
    output reg[31:0] TLBVirtualAddress,
    output reg TLBWriteEnable,
    output reg[31:0] Address,
    output reg WriteEnable,
    output reg DataSize,
    output reg[31:0] WriteData,
    output reg PauseSignal,
    output reg ExReadTLBMiss,
    output reg ExWriteTLBMiss,
    output reg ExReadError,
    output reg ExWriteError,
    output reg PCReadTLBMiss,
    output reg[31:0] InstructionResult,
    output reg[31:0] LoadResult
);
    reg IsLoadStore;
    reg[31:0] LastResult;
    reg tempWriteEnable;
    reg tempDataSize;
    reg[31:0] tempWriteData;
    reg isFlush;
    reg tempSerialInterrupt;
    reg tempClockInterrupt;
    reg checkClockInterrupt;
    always @(posedge clock) begin
        if(reset == 1'b0) begin
            IsLoadStore <= 1'b0;
            LastResult <= 32'b0;
            isFlush <= 1'b0;
        end else if(ready == 1'b0) begin
        end else if(flushin == 1'b1) begin
            IsLoadStore <= 1'b0;
            LastResult <= ReadResult;
            isFlush <= 1'b1;
        end else if(RAMReadEnable == 1'b1 | RAMWriteEnable == 1'b1) begin
            IsLoadStore <= 1'b1;
            LastResult <= ReadResult;
            isFlush <= 1'b0;
        end else begin
            IsLoadStore <= 1'b0;
            LastResult <= ReadResult;
            isFlush <= 1'b0;
        end
    end
    always @(posedge clock) begin
        if(checkClockInterrupt == 1'b1) begin
            tempClockInterrupt <= 1'b0;
        end else begin
            tempClockInterrupt <= clockInterrupt | tempClockInterrupt;
        end
        tempSerialInterrupt <= SerialInterrupt;
    end
    always @(*) begin
        if(reset == 1'b0) begin
            InstructionResult <= 32'b0;
            LoadResult <= 32'b0;
        end else if(flushin == 1'b1) begin
            InstructionResult <= 32'b0;
            LoadResult <= 32'b0;
        end else if(IsLoadStore == 1'b1) begin
            InstructionResult <= LastResult;
            LoadResult <= ReadResult;
        end else begin
            if(isFlush) begin
                InstructionResult <= 32'b0;
            end else begin
                InstructionResult <= ReadResult;
            end
            LoadResult <= 32'b0;
        end
    end
    always @(*) begin
        if(reset == 1'b0) begin
            PauseSignal <= 1'b0;
        end else if(RAMReadEnable == 1'b1 | RAMWriteEnable == 1'b1) begin
            PauseSignal <= 1'b1;
        end else begin
            PauseSignal <= PauseRequest;
        end
    end
    always @(*) begin
        if(reset == 1'b0) begin
            Writeepc <= 1'b0;
            WriteepcData <= 32'b0;
            Writestatus <= 1'b0;
            WritestatusData <= 32'b0;
            Writecause <= 1'b0;
            WritecauseData <= 32'b0;
            Writebadaddr <= 1'b0;
            WritebadaddrData <= 32'b0;
            flush <= 1'b0;
            targetAddress <= 1'b0;
            checkClockInterrupt <= 1'b0;
        end else if(((tempClockInterrupt & cp0status[15]) | (tempSerialInterrupt & cp0status[12])) & cp0status[0] & (~cp0status[1])) begin
            if(tempClockInterrupt) begin
                checkClockInterrupt <= 1'b1;
            end else begin
                checkClockInterrupt <= 1'b0;
            end
            Writeepc <= 1'b1;
            if(isInDelaySlot) begin
                WriteepcData <= currentPC - 32'h00000004;
            end else begin
                WriteepcData <= currentPC;
            end
            Writestatus <= 1'b1;
            WritestatusData <= cp0status | 32'h00000002;
            Writecause <= 1'b1;
            WritecauseData <= {isInDelaySlot, cp0cause[30:16], tempClockInterrupt, cp0cause[14:13], tempSerialInterrupt, cp0cause[11:7], 7'b0000000};
            Writebadaddr <= 1'b0;
            WritebadaddrData <= 32'b0;
            flush <= 1'b1;
            targetAddress <= cp0base + 32'h00000180;
        end else if(TLBMissRead) begin
            Writeepc <= 1'b1;
            if(isInDelaySlot) begin
                WriteepcData <= currentPC - 32'h00000004;
            end else begin
                WriteepcData <= currentPC;
            end
            Writestatus <= 1'b1;
            WritestatusData <= cp0status | 32'h00000002;
            Writecause <= 1'b1;
            WritecauseData <= {isInDelaySlot, cp0cause[30:7], 7'b0001000};
            Writebadaddr <= 1'b1;
            WritebadaddrData <= excBadAddress;
            flush <= 1'b1;
            targetAddress <= cp0base;
            checkClockInterrupt <= 1'b0;
        end else if(TLBMissWrite) begin
            Writeepc <= 1'b1;
            if(isInDelaySlot) begin
                WriteepcData <= currentPC - 32'h00000004;
            end else begin
                WriteepcData <= currentPC;
            end
            Writestatus <= 1'b1;
            WritestatusData <= cp0status | 32'h00000002;
            Writecause <= 1'b1;
            WritecauseData <= {isInDelaySlot, cp0cause[30:7], 7'b0001100};
            Writebadaddr <= 1'b1;
            WritebadaddrData <= excBadAddress;
            flush <= 1'b1;
            targetAddress <= cp0base;
            checkClockInterrupt <= 1'b0;
        end else if(ReadError | (AddressReadPrivilege & cp0status[4] & (~cp0status[1]))) begin
            Writeepc <= 1'b1;
            if(isInDelaySlot) begin
                WriteepcData <= currentPC - 32'h00000004;
            end else begin
                WriteepcData <= currentPC;
            end
            Writestatus <= 1'b1;
            WritestatusData <= cp0status | 32'h00000002;
            Writecause <= 1'b1;
            WritecauseData <= {isInDelaySlot, cp0cause[30:7], 7'b0010000};
            Writebadaddr <= 1'b1;
            WritebadaddrData <= excBadAddress;
            flush <= 1'b1;
            targetAddress <= cp0base + 32'h00000180;
            checkClockInterrupt <= 1'b0;
        end else if(WriteError | (AddressWritePrivilege & cp0status[4] & (~cp0status[1]))) begin
            Writeepc <= 1'b1;
            if(isInDelaySlot) begin
                WriteepcData <= currentPC - 32'h00000004;
            end else begin
                WriteepcData <= currentPC;
            end
            Writestatus <= 1'b1;
            WritestatusData <= cp0status | 32'h00000002;
            Writecause <= 1'b1;
            WritecauseData <= {isInDelaySlot, cp0cause[30:7], 7'b0010100};
            Writebadaddr <= 1'b1;
            WritebadaddrData <= excBadAddress;
            flush <= 1'b1;
            targetAddress <= cp0base + 32'h00000180;
            checkClockInterrupt <= 1'b0;
        end else if(ValidInstruction | (InstructionPrivilege & cp0status[4] & (~cp0status[1]))) begin
            Writeepc <= 1'b1;
            if(isInDelaySlot) begin
                WriteepcData <= currentPC - 32'h00000004;
            end else begin
                WriteepcData <= currentPC;
            end
            Writestatus <= 1'b1;
            WritestatusData <= cp0status | 32'h00000002;
            Writecause <= 1'b1;
            WritecauseData <= {isInDelaySlot, cp0cause[30:7], 7'b0101000};
            Writebadaddr <= 1'b0;
            WritebadaddrData <= 32'b0;
            flush <= 1'b1;
            targetAddress <= cp0base + 32'h00000180;
            checkClockInterrupt <= 1'b0;
        end else if((currentPC == cp0watchLo && cp0watchLo != 32'b0) | (currentPC == cp0watchHi && cp0watchHi != 32'b0)) begin
            Writeepc <= 1'b1;
            if(isInDelaySlot) begin
                WriteepcData <= currentPC - 32'h00000004;
            end else begin
                WriteepcData <= currentPC;
            end
            Writestatus <= 1'b1;
            WritestatusData <= cp0status | 32'h00000002;
            Writecause <= 1'b1;
            WritecauseData <= {isInDelaySlot, cp0cause[30:7], 7'b1011100};
            Writebadaddr <= 1'b0;
            WritebadaddrData <= 32'b0;
            flush <= 1'b1;
            targetAddress <= cp0base + 32'h00000180;
            checkClockInterrupt <= 1'b0;
        end else if(syscall) begin
            Writeepc <= 1'b1;
            if(isInDelaySlot) begin
                WriteepcData <= currentPC - 32'h00000004;
            end else begin
                WriteepcData <= currentPC;
            end
            Writestatus <= 1'b1;
            WritestatusData <= cp0status | 32'h00000002;
            Writecause <= 1'b1;
            WritecauseData <= {isInDelaySlot, cp0cause[30:7], 7'b0100000};
            Writebadaddr <= 1'b0;
            WritebadaddrData <= 32'b0;
            flush <= 1'b1;
            targetAddress <= cp0base + 32'h00000180;
            checkClockInterrupt <= 1'b0;
        end else if(eret) begin
            Writeepc <= 1'b0;
            WriteepcData <= 32'b0;
            Writestatus <= 1'b1;
            WritestatusData <= cp0status & 32'hfffffffd;
            Writecause <= 1'b0;
            WritecauseData <= 32'b0;
            Writebadaddr <= 1'b0;
            WritebadaddrData <= 32'b0;
            flush <= 1'b1;
            targetAddress <= cp0epc;
            checkClockInterrupt <= 1'b0;
        end else begin
            Writeepc <= 1'b0;
            WriteepcData <= 32'b0;
            Writestatus <= 1'b0;
            WritestatusData <= 32'b0;
            Writecause <= 1'b0;
            WritecauseData <= 32'b0;
            Writebadaddr <= 1'b0;
            WritebadaddrData <= 32'b0;
            flush <= 1'b0;
            targetAddress <= 1'b0;
            checkClockInterrupt <= 1'b0;
        end
    end
    always @(*) begin
        if(reset == 1'b0) begin
            ExReadTLBMiss <= 1'b0;
            ExWriteTLBMiss <= 1'b0;
            ExReadError <= 1'b0;
            ExWriteError <= 1'b0;
            PCReadTLBMiss <= 1'b0;
        end else begin
            ExReadTLBMiss <= 1'b0;
            ExWriteTLBMiss <= 1'b0;
            ExReadError <= 1'b0;
            ExWriteError <= 1'b0;
            PCReadTLBMiss <= 1'b0;
            if(RAMWriteEnable == 1'b1) begin
                if(RAMAddress[1:0] != 2'b0 && RAMDataSize == 1'b1) begin
                    ExWriteError <= 1'b1;
                end else if(ValidAddress == 1'b0) begin
                    if(isMiss == 1'b1) begin
                        ExWriteTLBMiss <= 1'b1;
                    end else begin
                        ExWriteError <= 1'b1;
                    end
                end else begin
                end
            end else if(RAMReadEnable == 1'b1) begin
                if(RAMAddress[1:0] != 2'b0 && RAMDataSize == 1'b1) begin
                    ExReadError <= 1'b1;
                end else if(ValidAddress == 1'b0) begin
                    ExReadTLBMiss <= 1'b1;
                end
            end else if(ValidAddress == 1'b0) begin
                PCReadTLBMiss <= 1'b1;
            end else begin
            end
        end
    end
    always @(*) begin
        if(reset == 1'b0) begin
            Address <= 32'h1fc00000;
            WriteEnable <= 1'b0;
            DataSize <= 1'b1;
            WriteData <= 32'b0;
        end else if(flushin == 1'b1) begin
            Address <= targetAddress;
            WriteEnable <= 1'b0;
            DataSize <= 1'b1;
            WriteData <= 32'b0;
        end else if(ValidAddress == 1'b1) begin
            Address <= TLBPhysicalAddress;
            WriteEnable <= tempWriteEnable;
            DataSize <= tempDataSize;
            WriteData <= tempWriteData;
        end else begin
            Address <= 32'h1fc00000;
            WriteEnable <= 1'b0;
            DataSize <= 1'b1;
            WriteData <= 32'b0;
        end
    end
    always @(*) begin
        if(reset == 1'b0) begin
            TLBVirtualAddress <= RAMAddress;
            tempWriteEnable <= 1'b0;
            tempDataSize <= 1'b1;
            tempWriteData <= 32'b0;
            TLBWriteEnable <= 1'b0;
        end else if(RAMWriteEnable == 1'b1) begin
            TLBVirtualAddress <= RAMAddress;
            tempWriteEnable <= 1'b1;
            tempDataSize <= RAMDataSize;
            tempWriteData <= RAMData;
            TLBWriteEnable <= 1'b1;
        end else if(RAMReadEnable == 1'b1) begin
            TLBVirtualAddress <= RAMAddress;
            tempWriteEnable <= 1'b0;
            tempDataSize <= RAMDataSize;
            tempWriteData <= 32'b0;
            TLBWriteEnable <= 1'b0;
        end else if(BranchFlag == 1'b1) begin
            TLBVirtualAddress <= BranchTarget;
            tempWriteEnable <= 1'b0;
            tempDataSize <= 1'b1;
            tempWriteData <= 32'b0;
            TLBWriteEnable <= 1'b0;
        end else begin
            TLBVirtualAddress <= PCPlus4;
            tempWriteEnable <= 1'b0;
            tempDataSize <= 1'b1;
            tempWriteData <= 32'b0;
            TLBWriteEnable <= 1'b0;
        end
    end
endmodule
