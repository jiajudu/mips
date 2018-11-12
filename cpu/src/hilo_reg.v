`timescale 1ns / 1ps
module hilo_reg(
    input wire clock,
    input wire reset,
    input wire ready,
    input wire WriteHiEnable,
    input wire WriteLoEnable,
    input wire[31:0] HiIn,
    input wire[31:0] LoIn,
    output reg[31:0] HiOut,
    output reg[31:0] LoOut
);
    reg[31:0] Hi;
    reg[31:0] Lo;
    always @(posedge clock) begin
        if (reset == 1'b0) begin
            Hi <= 32'b0;
        end else if(ready == 1'b0) begin
        end else if ((WriteHiEnable == 1'b1)) begin
            Hi <= HiIn;
        end
    end
    always @(posedge clock) begin
        if (reset == 1'b0) begin
            Lo <= 32'b0;
        end else if(ready == 1'b0) begin
        end else if ((WriteLoEnable == 1'b1)) begin
            Lo <= LoIn;
        end
    end
    always @(*) begin
        if (reset == 1'b0) begin
            HiOut <= 32'b0;
        end else if (WriteHiEnable == 1'b1) begin
            HiOut <= HiIn;
        end else begin
            HiOut <= Hi;
        end
    end
    always @(*) begin
        if (reset == 1'b0) begin
            LoOut <= 32'b0;
        end else if (WriteLoEnable == 1'b1) begin
            LoOut <= LoIn;
        end else begin
            LoOut <= Lo;
        end
    end
endmodule