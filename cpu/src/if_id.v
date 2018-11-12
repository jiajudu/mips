`timescale 1ns / 1ps
module if_id(
    input wire clock,
    input wire reset,
    input wire ready,
    input wire flush,
    input wire[31:0] flushTarget, 
    input wire PauseSignal,
    input wire[31:0] PC,
    input wire[31:0] Instruction,
    input wire PCTLBMiss,
    input wire IsInDelaySlot,
    output reg[31:0] IdPC,
    output reg[31:0] IdInstruction,
    output reg PCTLBMissOut,
    output reg IsInDelaySlotOut
);
    always @ (posedge clock) begin
        if (reset == 1'b0) begin
            IdPC <= 32'b0;
            IdInstruction <= 32'b0;
            PCTLBMissOut <= 1'b0;
            IsInDelaySlotOut <= 1'b0;
        end else if(ready == 1'b0) begin
        end else if(flush == 1'b1) begin
            IdPC <= flushTarget;
            IdInstruction <= 32'b0;
            PCTLBMissOut <= 1'b0;
            IsInDelaySlotOut <= 1'b0;
        end else if(PauseSignal == 1'b1) begin
            IdPC <= IdPC;
            IdInstruction <= IdInstruction;
            PCTLBMissOut <= PCTLBMissOut;
            IsInDelaySlotOut <= IsInDelaySlotOut;
        end else begin
            IdPC <= PC;
            IdInstruction <= Instruction;
            PCTLBMissOut <= PCTLBMiss;
            IsInDelaySlotOut <= IsInDelaySlot;
        end
    end
endmodule