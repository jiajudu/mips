`timescale 1ns / 1ps
module VirtualFlash(
    input wire Hclock,
    input wire Hreset,
    input wire Hsize,
    input wire Hwrite,
    input wire[31:0] Hwritedata,
    input wire[23:0] Haddress,
    input wire Hselect,
    input wire ready,
    output reg[31:0] Hreaddata,
    output reg Hready,
    output reg Hresponse
);
    reg[15:0] rom[0:4194303];
    reg[23:0] address;
    initial $readmemh("kernel",rom);
    always @ (posedge Hclock) begin
        if(Hreset == 1'b0) begin
        end else if(Hselect==1'b1 && ready==1'b1) begin
            address <= Haddress;			
        end
    end
    always @(*) begin
        Hreaddata[15:0] <= rom[address[23:2]];
        Hreaddata[31:16] <= 16'b0;
        Hresponse <= 1'b0;
        Hready <= 1'b1;
    end
endmodule