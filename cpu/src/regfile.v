`timescale 1ns / 1ps
module regfile(
    input wire clock,
    input wire reset,
    input wire ready,
    input wire WriteEnable,
    input wire[4:0] WriteAddress,
    input wire[31:0] WriteData,
    input wire ReadEnable1,
    input wire[4:0] ReadAddress1,
    output reg[31:0] ReadData1,
    input wire ReadEnable2,
    input wire[4:0] ReadAddress2,
    output reg[31:0] ReadData2
);
    reg[31:0] register[0:31];
    always @ (posedge clock) begin
        if(reset == 1'b0) begin
            register[0] <= 32'b0;
            register[1] <= 32'b0;
            register[2] <= 32'b0;
            register[3] <= 32'b0;
            register[4] <= 32'b0;
            register[5] <= 32'b0;
            register[6] <= 32'b0;
            register[7] <= 32'b0;
            register[8] <= 32'b0;
            register[9] <= 32'b0;
            register[10] <= 32'b0;
            register[11] <= 32'b0;
            register[12] <= 32'b0;
            register[13] <= 32'b0;
            register[14] <= 32'b0;
            register[15] <= 32'b0;
            register[16] <= 32'b0;
            register[17] <= 32'b0;
            register[18] <= 32'b0;
            register[19] <= 32'b0;
            register[20] <= 32'b0;
            register[21] <= 32'b0;
            register[22] <= 32'b0;
            register[23] <= 32'b0;
            register[24] <= 32'b0;
            register[25] <= 32'b0;
            register[26] <= 32'b0;
            register[27] <= 32'b0;
            register[28] <= 32'b0;
            register[29] <= 32'b0;
            register[30] <= 32'b0;
            register[31] <= 32'b0;
        end else if(ready == 1'b0) begin
        end else begin
            if((WriteEnable == 1'b1) && (WriteAddress != 5'b0)) begin
                register[WriteAddress] <= WriteData;
            end
        end
    end
    always @ (*) begin
        if(reset == 1'b0) begin
            ReadData1 <= 32'b0;
        end else if(ReadAddress1 == 5'b0) begin
            ReadData1 <= 32'b0;
        end else if((ReadAddress1 == WriteAddress) && (WriteEnable == 1'b1) && (ReadEnable1 == 1'b1)) begin
            ReadData1 <= WriteData;
        end else if(ReadEnable1 == 1'b1) begin
            ReadData1 <= register[ReadAddress1];
        end else begin
            ReadData1 <= 32'b0;
        end
    end
    always @ (*) begin
        if(reset == 1'b0) begin
            ReadData2 <= 32'b0;
        end else if(ReadAddress2 == 5'b0) begin
            ReadData2 <= 32'b0;
        end else if((ReadAddress2 == WriteAddress) && (WriteEnable == 1'b1) && (ReadEnable2 == 1'b1)) begin
            ReadData2 <= WriteData;
        end else if(ReadEnable2 == 1'b1) begin
            ReadData2 <= register[ReadAddress2];
        end else begin
            ReadData2 <= 32'b0;
        end
    end
endmodule