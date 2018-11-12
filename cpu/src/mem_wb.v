`timescale 1ns / 1ps
module mem_wb(
    input wire clock,
    input wire reset,
    input wire ready,
    input wire flush,
    input wire[4:0] MemWriteAddress,
    input wire MemWriteRegister,
    input wire[31:0] MemWriteData,
    input wire[31:0] MemHi,
    input wire[31:0] MemLo,
    input wire MemWriteHi,
    input wire MemWriteLo,
    input wire MemWriteCP,
    input wire[4:0] MemWriteCPAddress,
    input wire[31:0] MemWriteCPData,
    input wire MemWriteepc,
    input wire[31:0] MemWriteepcData,
    input wire MemWritestatus,
    input wire[31:0] MemWritestatusData,
    input wire MemWritecause,
    input wire[31:0] MemWritecauseData,
    input wire MemWritebadaddr,
    input wire[31:0] MemWritebadaddrData,
    output reg[4:0] WbWriteAddress,
    output reg WbWriteRegister,
    output reg[31:0] WbWriteData,
    output reg[31:0] WbHi,
    output reg[31:0] WbLo,
    output reg WbWriteHiOut,
    output reg WbWriteLoOut,
    output reg Write0,
    output reg Write2,
    output reg Write3,
    output reg Write8,
    output reg Write10,
    output reg Write11,
    output reg Write12,
    output reg Write13,
    output reg Write14,
    output reg Write15,
    output reg Write18,
    output reg Write19,
    output reg[31:0] Write0Data,
    output reg[31:0] Write2Data,
    output reg[31:0] Write3Data,
    output reg[31:0] Write8Data,
    output reg[31:0] Write10Data,
    output reg[31:0] Write11Data,
    output reg[31:0] Write12Data,
    output reg[31:0] Write13Data,
    output reg[31:0] Write14Data,
    output reg[31:0] Write15Data,
    output reg[31:0] Write18Data,
    output reg[31:0] Write19Data
);
    reg WriteCP;
    reg[4:0] WriteCPAddress;
    reg[31:0] WriteCPData;
    reg Writeepc;
    reg[31:0] WriteepcData;
    reg Writestatus;
    reg[31:0] WritestatusData;
    reg Writecause;
    reg[31:0] WritecauseData;
    reg Writebadaddr;
    reg[31:0] WritebadaddrData;
    always @ (posedge clock) begin
        if(reset == 1'b0) begin
            WbWriteAddress <= 5'b0;
            WbWriteRegister <= 1'b0;
            WbWriteData <= 32'b0;
            WbHi <= 32'b0;
            WbLo <= 32'b0;
            WbWriteHiOut <= 1'b0;
            WbWriteLoOut <= 1'b0;
            WriteCP <= 1'b0;
            WriteCPAddress <= 5'b0;
            WriteCPData <= 32'b0;
            Writeepc <= 1'b0;
            WriteepcData <= 32'b0;
            Writestatus <= 1'b0;
            WritestatusData <= 32'b0;
            Writecause <= 1'b0;
            WritecauseData <= 32'b0;
            Writebadaddr <= 1'b0;
            WritebadaddrData <= 32'b0;
        end else if(ready == 1'b0) begin
        end else begin
            if(flush == 1'b1) begin
                WbWriteAddress <= 5'b0;
                WbWriteRegister <= 1'b0;
                WbWriteData <= 32'b0;
                WbHi <= 32'b0;
                WbLo <= 32'b0;
                WbWriteHiOut <= 1'b0;
                WbWriteLoOut <= 1'b0;
                WriteCP <= 1'b0;
                WriteCPAddress <= 5'b0;
                WriteCPData <= 32'b0;
            end else begin
                WbWriteAddress <= MemWriteAddress;
                WbWriteRegister <= MemWriteRegister;
                WbWriteData <= MemWriteData;
                WbHi <= MemHi;
                WbLo <= MemLo;
                WbWriteHiOut <= MemWriteHi;
                WbWriteLoOut <= MemWriteLo;
                WriteCP <= MemWriteCP;
                WriteCPAddress <= MemWriteCPAddress;
                WriteCPData <= MemWriteCPData;
            end
            Writeepc <= MemWriteepc;
            WriteepcData <= MemWriteepcData;
            Writestatus <= MemWritestatus;
            WritestatusData <= MemWritestatusData;
            Writecause <= MemWritecause;
            WritecauseData <= MemWritecauseData;
            Writebadaddr <= MemWritebadaddr;
            WritebadaddrData <= MemWritebadaddrData;
        end
    end
    always @(*) begin
        Write0 <= 1'b0;
        Write2 <= 1'b0;
        Write3 <= 1'b0;
        Write8 <= 1'b0;
        Write10 <= 1'b0;
        Write11 <= 1'b0;
        Write12 <= 1'b0;
        Write13 <= 1'b0;
        Write14 <= 1'b0;
        Write15 <= 1'b0;
        Write18 <= 1'b0;
        Write19 <= 1'b0;
        Write0Data <= 32'b0;
        Write2Data <= 32'b0;
        Write3Data <= 32'b0;
        Write8Data <= 32'b0;
        Write10Data <= 32'b0;
        Write11Data <= 32'b0;
        Write12Data <= 32'b0;
        Write13Data <= 32'b0;
        Write14Data <= 32'b0;
        Write15Data <= 32'b0;
        Write18Data <= 32'b0;
        Write19Data <= 32'b0;
        if(Writeepc | Writestatus | Writecause | Writebadaddr) begin
            Write14 <= Writeepc;
            Write14Data <= WriteepcData;
            Write12 <= Writestatus;
            Write12Data <= WritestatusData;
            Write13 <= Writecause;
            Write13Data <= WritecauseData;
            Write8 <= Writebadaddr;
            Write8Data <= WritebadaddrData;
        end
        if(WriteCP == 1'b1)begin
            case(WriteCPAddress)
                5'b00000:begin
                    Write0 <= 1'b1;
                    Write0Data <= WriteCPData;
                end
                5'b00010:begin
                    Write2 <= 1'b1;
                    Write2Data <= WriteCPData;
                end
                5'b00011:begin
                    Write3 <= 1'b1;
                    Write3Data <= WriteCPData;
                end
                5'b01000:begin
                    Write8 <= 1'b1;
                    Write8Data <= WriteCPData;
                end
                5'b01010:begin
                    Write10 <= 1'b1;
                    Write10Data <= WriteCPData;
                end
                5'b01011:begin
                    Write11 <= 1'b1;
                    Write11Data <= WriteCPData;
                end
                5'b01100:begin
                    Write12 <= 1'b1;
                    Write12Data <= WriteCPData;
                end
                5'b01101:begin
                    Write13 <= 1'b1;
                    Write13Data <= WriteCPData;
                end
                5'b01110:begin
                    Write14 <= 1'b1;
                    Write14Data <= WriteCPData;
                end
                5'b01111:begin
                    Write15 <= 1'b1;
                    Write15Data <= WriteCPData;
                end
                5'b10010:begin
                    Write18 <= 1'b1;
                    Write18Data <= WriteCPData;
                end
                5'b10011:begin
                    Write19 <= 1'b1;
                    Write19Data <= WriteCPData;
                end
                default:begin
                end
            endcase
        end
    end
endmodule