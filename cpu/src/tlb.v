`timescale 1ns / 1ps
module tlb(
    input wire clock,
    input wire reset,
    input wire[31:0] VirtualAddress,
    input wire WriteEnable,
    input wire WriteTLB,
    input wire[31:0] index,
    input wire[31:0] entryLo0,
    input wire[31:0] entryLo1,
    input wire[31:0] entryHi,
    output reg ValidAddress,
    output reg isMiss,//miss or wrong privilege?
    output reg[31:0] PhysicalAddress
);
    reg[63:0] TLB[0:15];
    reg[3:0] matchIndex;
    reg isMatch;
    always @(posedge clock) begin
        if(reset == 1'b0) begin
            TLB[0] <= 64'h4000000000000000;
            TLB[1] <= 64'h4000000000000000;
            TLB[2] <= 64'h4000000000000000;
            TLB[3] <= 64'h4000000000000000;
            TLB[4] <= 64'h4000000000000000;
            TLB[5] <= 64'h4000000000000000;
            TLB[6] <= 64'h4000000000000000;
            TLB[7] <= 64'h4000000000000000;
            TLB[8] <= 64'h4000000000000000;
            TLB[9] <= 64'h4000000000000000;
            TLB[10] <= 64'h4000000000000000;
            TLB[11] <= 64'h4000000000000000;
            TLB[12] <= 64'h4000000000000000;
            TLB[13] <= 64'h4000000000000000;
            TLB[14] <= 64'h4000000000000000;
            TLB[15] <= 64'h4000000000000000;
        end else begin
            if(WriteTLB == 1'b1) begin
                TLB[index[3:0]][62:44] <= entryHi[31:13];
                TLB[index[3:0]][43:24] <= entryLo0[25:6];
                TLB[index[3:0]][23] <= entryLo0[1];
                TLB[index[3:0]][22] <= entryLo0[2];
                TLB[index[3:0]][21:2] <= entryLo1[25:6];
                TLB[index[3:0]][1] <= entryLo1[1];
                TLB[index[3:0]][0] <= entryLo1[2];
            end
        end
    end
    always @(*) begin
        if(reset == 1'b0) begin
            PhysicalAddress <= 32'b0;
            ValidAddress <= 1'b1;
            isMiss <= 1'b1;
            isMatch <= 1'b0;
            matchIndex <= 4'b0000;
        end else if(VirtualAddress[31:30] == 2'b10) begin
            PhysicalAddress <= VirtualAddress & 32'h1fffffff;
            ValidAddress <= 1'b1;
            isMiss <= 1'b1;
            isMatch <= 1'b0;
            matchIndex <= 4'b0000;
        end else begin 
            if(VirtualAddress[31:13] == TLB[0][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b0000;
            end else if(VirtualAddress[31:13] == TLB[1][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b0001;
            end else if(VirtualAddress[31:13] == TLB[2][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b0010;
            end else if(VirtualAddress[31:13] == TLB[3][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b0011;
            end else if(VirtualAddress[31:13] == TLB[4][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b0100;
            end else if(VirtualAddress[31:13] == TLB[5][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b0101;
            end else if(VirtualAddress[31:13] == TLB[6][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b0110;
            end else if(VirtualAddress[31:13] == TLB[7][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b0111;
            end else if(VirtualAddress[31:13] == TLB[8][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b1000;
            end else if(VirtualAddress[31:13] == TLB[9][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b1001;
            end else if(VirtualAddress[31:13] == TLB[10][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b1010;
            end else if(VirtualAddress[31:13] == TLB[11][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b1011;
            end else if(VirtualAddress[31:13] == TLB[12][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b1100;
            end else if(VirtualAddress[31:13] == TLB[13][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b1101;
            end else if(VirtualAddress[31:13] == TLB[14][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b1110;
            end else if(VirtualAddress[31:13] == TLB[15][62:44]) begin
                isMatch <= 1'b1;
                matchIndex <= 4'b1111;
            end else begin
                isMatch <= 1'b0;
                matchIndex <= 4'b0000;
            end
            if(isMatch == 1'b1) begin
                if(VirtualAddress[12] == 1'b0) begin
                    if(TLB[matchIndex][23] == 1'b0) begin
                        PhysicalAddress <= 32'b0;
                        ValidAddress <= 1'b0;
                        isMiss <= 1'b1;
                    end else if(WriteEnable == 1'b1) begin
                        if(TLB[matchIndex][22] == 1'b1) begin
                            PhysicalAddress <= {TLB[matchIndex][43:24],VirtualAddress[11:0]};
                            ValidAddress <= 1'b1;
                            isMiss <= 1'b0;
                        end else begin
                            PhysicalAddress <= 32'b0;
                            ValidAddress <= 1'b0;
                            isMiss <= 1'b0;
                        end
                    end else begin
                        PhysicalAddress <= {TLB[matchIndex][43:24],VirtualAddress[11:0]};
                        ValidAddress <= 1'b1;
                        isMiss <= 1'b0;
                    end
                end else begin
                    if(TLB[matchIndex][1] == 1'b0) begin
                        PhysicalAddress <= 32'b0;
                        ValidAddress <= 1'b0;
                        isMiss <= 1'b1;
                    end else if(WriteEnable == 1'b1) begin
                        if(TLB[matchIndex][0] == 1'b1) begin
                            PhysicalAddress <= {TLB[matchIndex][21:2],VirtualAddress[11:0]};
                            ValidAddress <= 1'b1;
                            isMiss <= 1'b0;
                        end else begin
                            PhysicalAddress <= 32'b0;
                            ValidAddress <= 1'b0;
                            isMiss <= 1'b0;
                        end
                    end else begin
                        PhysicalAddress <= {TLB[matchIndex][21:2],VirtualAddress[11:0]};
                        ValidAddress <= 1'b1;
                        isMiss <= 1'b0;
                    end
                end
            end else begin
                PhysicalAddress <= 32'b0;
                ValidAddress <= 1'b0;
                isMiss <= 1'b1;
            end
        end
    end
endmodule
