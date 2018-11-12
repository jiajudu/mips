`timescale 1ns / 1ps
module cp(
    input wire clock,
    input wire reset,
    input wire ready,
    input wire[4:0] address,
    input wire write0,
    input wire write2,
    input wire write3,
    input wire write8,
    input wire write10,
    input wire write11,
    input wire write12,
    input wire write13,
    input wire write14,
    input wire write15,
    input wire write18,
    input wire write19,
    input wire[31:0] write0data,
    input wire[31:0] write2data,
    input wire[31:0] write3data,
    input wire[31:0] write8data,
    input wire[31:0] write10data,
    input wire[31:0] write11data,
    input wire[31:0] write12data,
    input wire[31:0] write13data,
    input wire[31:0] write14data,
    input wire[31:0] write15data,
    input wire[31:0] write18data,
    input wire[31:0] write19data,
    output reg clockInterrupt,
    output reg[31:0] value,
    output reg[31:0] index0Out,
    output reg[31:0] entryLo02Out,
    output reg[31:0] entryLo13Out,
    output reg[31:0] entryHi10Out,
    output reg[31:0] status12Out,
    output reg[31:0] cause13Out,
    output reg[31:0] epc14Out,
    output reg[31:0] ebase15Out,
    output reg[31:0] watchLo18Out,
    output reg[31:0] watchHi19Out
);
    reg[31:0] index0;
    reg[31:0] entryLo02;
    reg[31:0] entryLo13;
    reg[31:0] badaddr8;
    reg[31:0] count9;
    reg[31:0] entryHi10;
    reg[31:0] compare11;
    reg[31:0] status12;
    reg[31:0] cause13;
    reg[31:0] epc14;
    reg[31:0] ebase15;
    reg[31:0] watchLo18;
    reg[31:0] watchHi19;
    reg[31:0] badaddr8Out;
    reg[31:0] count9Out;
    reg[31:0] compare11Out;
    always @(posedge clock) begin
        if(reset == 1'b0) begin
            index0 <= 32'b0;
            entryLo02 <= 32'b0;
            entryLo13 <= 32'b0;
            badaddr8 <= 32'b0;
            count9 <= 32'b0;
            entryHi10 <= 32'b0;
            compare11 <= 32'b0;
            status12 <= 32'b0;
            cause13 <= 32'b0;
            epc14 <= 32'b0;
            ebase15 <= 32'b0;
            watchLo18 <= 32'b0;
            watchHi19 <= 32'b0;
        end else if(ready == 1'b0) begin
        end else begin
            count9 <= count9 + 1;
            if(compare11 != 32'b0 && count9 == compare11) begin
                clockInterrupt <= 1'b1;
            end else begin
                clockInterrupt <= 1'b0;
            end
            if(write0 == 1'b1) begin
                index0 <= write0data;
            end
            if(write2 == 1'b1) begin
                entryLo02 <= write2data;
            end
            if(write3 == 1'b1) begin
                entryLo13 <= write3data;
            end
            if(write8 == 1'b1) begin
                badaddr8 <= write8data;
            end
            if(write10 == 1'b1) begin
                entryHi10 <= write10data;
            end
            if(write11 == 1'b1) begin
                compare11 <= write11data;
            end
            if(write12 == 1'b1) begin
                status12 <= write12data;
            end
            if(write13 == 1'b1) begin
                cause13 <= write13data;
            end
            if(write14 == 1'b1) begin
                epc14 <= write14data;
            end
            if(write15 == 1'b1) begin
                ebase15 <= write15data;
            end
            if(write18 == 1'b1) begin
                watchLo18 <= write18data;
            end
            if(write19 == 1'b1) begin
                watchHi19 <= write19data;
            end
        end
    end
    always @(*) begin
        if(reset == 1'b0) begin
            value <= 32'b0;
            index0Out <= 32'b0;
            entryLo02Out <= 32'b0;
            entryLo13Out <= 32'b0;
            badaddr8Out <= 32'b0;
            count9Out <= 32'b0;
            entryHi10Out <= 32'b0;
            compare11Out <= 32'b0;
            status12Out <= 32'b0;
            cause13Out <= 32'b0;
            epc14Out <= 32'b0;
            ebase15Out <= 32'b0;
            watchLo18Out <= 32'b0;
            watchHi19Out <= 32'b0;
        end else begin
            count9Out <= count9;
            if(write0 == 1'b1) begin
                index0Out <= write0data;
            end else begin
                index0Out <= index0;
            end
            if(write2 == 1'b1) begin
                entryLo02Out <= write2data;
            end else begin
                entryLo02Out <= entryLo02;
            end
            if(write3 == 1'b1) begin
                entryLo13Out <= write3data;
            end else begin
                entryLo13Out <= entryLo13;
            end
            if(write8 == 1'b1) begin
                badaddr8Out <= write8data;
            end else begin
                badaddr8Out <= badaddr8;
            end
            if(write10 == 1'b1) begin
                entryHi10Out <= write10data;
            end else begin
                entryHi10Out <= entryHi10;
            end
            if(write11 == 1'b1) begin
                compare11Out <= write11data;
            end else begin
                compare11Out <= compare11;
            end
            if(write12 == 1'b1) begin
                status12Out <= write12data;
            end else begin
                status12Out <= status12;
            end
            if(write13 == 1'b1) begin
                cause13Out <= write13data;
            end else begin
                cause13Out <= cause13;
            end
            if(write14 == 1'b1) begin
                epc14Out <= write14data;
            end else begin
                epc14Out <= epc14;
            end
            if(write15 == 1'b1) begin
                ebase15Out <= write15data;
            end else begin
                ebase15Out <= ebase15;
            end
            if(write18 == 1'b1) begin
                watchLo18Out <= write18data;
            end else begin
                watchLo18Out <= watchLo18;
            end
            if(write19 == 1'b1) begin
                watchHi19Out <= write19data;
            end else begin
                watchHi19Out <= watchHi19;
            end
            case (address)
                5'b00000:
                    value <= index0Out;
                5'b00010:
                    value <= entryLo02Out;
                5'b00011:
                    value <= entryHi10Out;
                5'b01000:
                    value <= badaddr8Out;
                5'b01001:
                    value <= count9Out;
                5'b01010:
                    value <= entryHi10Out;
                5'b01011:
                    value <= compare11Out;
                5'b01100:
                    value <= status12Out;
                5'b01101:
                    value <= cause13Out;
                5'b01110:
                    value <= epc14Out;
                5'b01111:
                    value <= ebase15Out;
                5'b10010:
                    value <= watchLo18Out;
                5'b10011:
                    value <= watchHi19Out;
                default:
                    value <= 32'b0;
            endcase
        end
    end
endmodule
