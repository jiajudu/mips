`timescale 1ns / 1ps
module VirtualSerial(
    input wire Hclock,
    input wire Hreset,
    input wire Hsize,
    input wire Hwrite,
    input wire[31:0] Hwritedata,
    input wire[2:0] Haddress,
    input wire Hselect,
    input wire ready,
    output reg[31:0] Hreaddata,
    output reg Hready,
    output reg Hresponse
);
    reg[7:0] data;
    reg write;
    reg[3:0] count;
    always @ (posedge Hclock) begin
        if(Hreset==1'b0) begin
            write <= 1'b0;
            data <= 8'b0;
            count <= 4'b0;
        end else begin
            if(Hselect==1'b1 && ready==1'b1) begin
                write <= Hwrite;
                if(Hwrite == 1'b1) begin
                    count <= 4'b0001;
                    data <= Hwritedata[7:0];
                    $write("%c",Hwritedata[7:0]);
                end
            end else begin
                if(count == 4'b1111) begin
                    count <= count;
                end else begin
                    count <= count + 1;
                end
            end
        end
    end
    always @(*) begin
        Hreaddata <= 32'b1;
        Hresponse <= 1'b0;
        if(count < 4'b0001) begin
            Hready <= 1'b0;
        end else begin
            Hready <= 1'b1;
        end
    end
endmodule
