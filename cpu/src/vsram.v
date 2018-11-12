`timescale 1ns / 1ps
module vsram(
    input wire Ram1OE,
    input wire Ram1WE,
    input wire Ram1EN,
    input wire[19:0] Ram1Address,
    inout wire[31:0] Ram1data
);
    reg sclock;
    reg[31:0] data_temp;
    assign Ram1data = (Ram1WE == 1'b1)?data_temp:32'bz;
    initial begin
        sclock = 1'b1;
        forever #10 sclock = ~sclock;
    end
    reg[31:0] data[0:1048575];
    initial $readmemh("sramdata", data);
    always @(posedge sclock) begin
        if(Ram1EN == 1'b0) begin
            if(Ram1WE == 1'b0 && Ram1OE == 1'b1) begin
                data[Ram1Address] <= Ram1data;
            end else if(Ram1WE == 1'b1 && Ram1OE == 1'b0) begin
                data_temp <= data[Ram1Address];
            end else begin
                data_temp <= 32'b0;
            end
        end else begin
        end
    end
endmodule