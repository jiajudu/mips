`timescale 1ns / 1ps
module ps2(
    input wire Hclock,
    input wire Hreset,
    output reg [7:0] receiveData,
    output reg Hready,
    input wire ps2data,
    input wire ps2clk
);
    reg[7:0] data;
    reg[8:0] temp_data;
    reg clk1, clk2;
    reg[3:0] status;
    reg parity;
    always@(posedge Hclock) begin
        clk1 <= ps2clk;
        clk2 <= clk1;
        if(Hreset == 1'b0) begin
            status <= 4'd0;
            parity <= 1'b0;
            temp_data <= 9'b0;
            receiveData <= 8'b0;
            data <= 8'b0;
            Hready <= 1'b0;
        end else begin
            if((!clk1)&clk2) begin
                if(status == 0) begin
                    if(ps2data == 1'b0) begin
                        status <= 4'd1;
                    end
                    parity <= 1'b0;
                    Hready <= 1'b0;
                end else if(status <9) begin
                    temp_data[status] <= ps2data;
                    status <= status + 1;
                    parity <= (parity ^ ps2data);
                    Hready <= 1'b0;
                end else if(status == 9) begin
                    if((parity ^ ps2data) == 1'b1) begin
                        data <= temp_data[8:1];
                    end
                    status <= status + 1;
                    Hready <= 1'b0;
                end else if(status == 10) begin
                    if(ps2data == 1'b1) status <= 0;
                    Hready <= 1'b1;
                    receiveData <= data;
                end
            end else begin
                Hready <= 1'b0;
                receiveData <= 8'b0;
            end
        end
    end
endmodule