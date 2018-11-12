`timescale 1ns / 1ps
module mem(
    input wire reset,
    input wire[4:0] WriteAddressIn,
    input wire WriteRegisterIn,
    input wire[31:0] WriteDataIn,
    input wire[31:0] HiIn,
    input wire[31:0] LoIn,
    input wire WriteHiIn,
    input wire WriteLoIn,
    input wire SignExtend,
    input wire RAMReadEnable,
    input wire[31:0] RAMData,
    input wire WriteCP,
    input wire[4:0] WriteCPAddress,
    input wire[31:0] WriteCPData,
    output reg[4:0] WriteAddressOut,
    output reg WriteRegisterOut,
    output reg[31:0] WriteDataOut,
    output reg[31:0] HiOut,
    output reg[31:0] LoOut,
    output reg WriteHiOut,
    output reg WriteLoOut,
    output reg WriteCPOut,
    output reg[4:0] WriteCPAddressOut,
    output reg[31:0] WriteCPDataOut
);
    always @ (*) begin
        if(reset == 1'b0) begin
            WriteAddressOut <= 5'b00000;
            WriteRegisterOut <= 1'b0;
            WriteDataOut <= 32'b0;
            HiOut <= 32'b0;
            LoOut <= 32'b0;
            WriteHiOut <= 1'b0;
            WriteLoOut <= 1'b0;
            WriteCPOut <= 1'b0;
            WriteCPAddressOut <= 5'b0;
            WriteCPDataOut <= 32'b0;
        end else begin
            WriteAddressOut <= WriteAddressIn;
            WriteRegisterOut <= WriteRegisterIn;
            if(RAMReadEnable == 1'b1) begin
                if(SignExtend == 1'b1) begin
                    WriteDataOut <= {{24{RAMData[7]}},RAMData[7:0]};
                end else begin
                    WriteDataOut <= RAMData;
                end
            end else begin
                WriteDataOut <= WriteDataIn;
            end
            HiOut <= HiIn;
            LoOut <= LoIn;
            WriteHiOut <= WriteHiIn;
            WriteLoOut <= WriteLoIn;
            WriteCPOut <= WriteCP;
            WriteCPAddressOut <= WriteCPAddress;
            WriteCPDataOut <= WriteCPData; 
        end
    end
endmodule