`timescale 1ns / 1ps
module VirtualRom(
    input wire Hclock,
    input wire Hreset,
    input wire Hsize,
    input wire Hwrite,
    input wire[31:0] Hwritedata,
    input wire[8:0] Haddress,
    input wire Hselect,
    input wire ready,
    output reg[31:0] Hreaddata,
    output reg Hready,
    output reg Hresponse
);
    reg[31:0] rom[0:127];
    reg[8:0] address;
    always @ (posedge Hclock) begin
        if(Hreset == 1'b0) begin
        end else if(Hselect==1'b1 && ready==1'b1) begin
            address <= Haddress;		
        end
    end
    always @(*) begin
        Hreaddata <= rom[address[8:2]];
        Hresponse <= 1'b0;
        Hready <= 1'b1;
    end
    initial $readmemh("bootfile", rom);
endmodule
