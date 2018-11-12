`timescale 1ns / 1ps
module PCRegister(
    input wire clock,
    input wire reset,
    input wire ready,
    input wire PauseSignal,
    input wire BranchFlag,
    input wire[31:0] BranchTarget,
    input wire PCTLBMiss,
    input wire flush,
    input wire[31:0] flushTarget,
    output reg[31:0] PC,
    output reg[31:0] PCPlus4,
    output reg PCTLBMissOut
);
    reg fix;
    always @ (posedge clock) begin
        if (reset == 1'b0) begin
            PC <= 32'hbfbffffc;
            PCTLBMissOut <= PCTLBMiss;
            fix <= 1'b0;
        end else if(ready == 1'b0) begin
        end else if(flush == 1'b1) begin
            PC <= flushTarget;
            PCTLBMissOut <= 1'b0;
            fix <= 1'b1;
        end else if(PauseSignal == 1'b1) begin
            PC <= PC;
            PCTLBMissOut <= PCTLBMissOut;
            fix <= 1'b0;
        end else if(BranchFlag == 1'b1) begin
            PC <= BranchTarget;
            PCTLBMissOut <= PCTLBMiss;
            fix <= 1'b0;
        end else begin
            if(fix == 1'b0) begin
                PC <= PC + 4'h4;
            end else begin
                PC <= PC;
            end
            PCTLBMissOut <= PCTLBMiss;
            fix <= 1'b0;
        end
    end
    always @ (*) begin
        if(fix == 1'b0) begin
            PCPlus4 <= PC + 4'h4;
        end else begin
            PCPlus4 <= PC;
        end
    end
endmodule