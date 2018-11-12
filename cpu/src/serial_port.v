`timescale 1ns / 1ps
module serial_port(
    input wire Hclock,
    input wire Hreset,
    input wire ready,
    input wire[7:0] Hwritedata,
    input wire Hselect,
    input wire Hwrite,
    input wire[2:0] Haddress,
    output reg[7:0] receiveData,
    output reg break,
    output wire Hready,
    output reg Hresponse,
    output wire TxD,
    input wire RxD,
    input wire ps2clk,
    input wire ps2data
);
    wire RxD_data_ready;
    wire[7:0] RxD_data;
    wire[7:0] TxD_data;
    wire Kbd_data_ready;
    wire[7:0] Kbd_data;
    wire TxD_busy;
    wire TxD_start;
    reg _TxD_busy;
    reg _TxD_start;
    reg[7:0] _TxD_data;
    assign TxD_start = _TxD_start;
    assign TxD_data = _TxD_data;
    reg _Hready;
    assign Hready = ((~TxD_busy) & _TxD_busy)|_Hready;
    reg[3:0] state;
    reg[7:0] outdata[15:0];
    reg[7:0] indata[15:0];
    reg[3:0] incount;
    reg[3:0] incurrent;
    assign readable = (incurrent != incount);
    assign ready_to_write = 1 ;
    always@(posedge Hclock or negedge Hreset) begin
        if(Hreset == 0) begin
            incount <= 4'b0;
            incurrent <= 4'b0;
            break <= 1'b0;
            receiveData <= 8'b0;
            _TxD_busy <= TxD_busy;
            _Hready <= 1'b0;
        end else begin
            // when cpu transmit and receive from serial port
            _TxD_busy <=TxD_busy;
            Hresponse <= 1'b0;
            if(Hselect == 1 && ready == 1) begin
                if(Hwrite == 1) begin
                    _TxD_start <= 1'b1;
                    _TxD_data <= Hwritedata;
                    _Hready <= 1'b0;
                end else begin
                    _Hready <= 1'b1;
                    _TxD_start <= 1'b0;
                    if(Haddress == 3'b000) begin     //read data register
                        receiveData <= indata[incurrent];
                        incurrent <= (incurrent + 1'b1) & {4{1'b1}};
                    end else begin              //read control register
                        receiveData <= {6'b0,readable,ready_to_write};
                        incurrent <= incurrent;
                    end
                end
            end else begin
                _TxD_start <= 1'b0;
            end
            if(RxD_data_ready == 1) begin
                indata[incount] <= RxD_data;
                incount <= (incount + 1'b1) & {4{1'b1}};
                break <= 1'b1;
            end else if(Kbd_data_ready == 1) begin
                indata[incount] <= Kbd_data;
                incount <= (incount + 1'b1) & {4{1'b1}};
                break <= 1'b1;
            end else begin
                incount <= incount;
                if(ready == 1) begin
                    break <= 1'b0;
                end else begin
                    break <= break;
                end
            end
        end
    end
    async_receiver RX(.clk(Hclock), .RxD(RxD), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
    async_transmitter TX(.clk(Hclock), .TxD(TxD), .TxD_start(TxD_start), .TxD_data(TxD_data), .TxD_busy(TxD_busy));
    keyboardControl kC0(.Hclock(Hclock), .Hreset(Hreset), .ps2data(ps2data), .ps2clk(ps2clk), .Hready(Kbd_data_ready), .data(Kbd_data));
endmodule
