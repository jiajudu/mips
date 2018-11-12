`timescale 1ns / 1ps
module top(
    input wire clock,
    input wire reset,
    output wire Ram1OE,
    output wire Ram1WE,
    output wire Ram1EN,
    output wire[19:0] Ram1Address,
    inout wire[31:0] Ram1data,
    input wire RxD,
    output wire TxD,
    output wire CE0,
    output wire BYTE,
    output wire VPEN,
    output wire RP,
    output wire OE,
    output wire WE,
    output wire[22:0] flashAddress,
    inout wire[15:0] flashdata,
    output wire vs,
    output wire hs,
    output wire[2:0] r,
    output wire[2:0] g,
    output wire[2:0] b,
    input wire ps2clk,
    input wire ps2data
);
    wire[31:0] CPURomData;
    wire[31:0] CPUAddress;
    wire CPUWriteEnable;
    wire CPUDataSize;
    wire[31:0] CPUWriteData;
    wire Hresponse;
    wire Hready;
    wire clk1;
    clkChanger cc1(.clk1(clock),.clk2(clk1));
    cpu cpu0(
        .clock(clk1),
        .reset(reset),
        .CPUBusReady(Hready),
        .CPURomData(CPURomData),
        .CPUBusResponse(Hresponse),
        .CPUSerialInterrupt(break),
        .CPUAddress(CPUAddress),
        .CPUWriteEnable(CPUWriteEnable),
        .CPUDataSize(CPUDataSize),
        .CPUWriteData(CPUWriteData)
    );
    bus bus0(
        .Hclock(clk1),
        .Hreset(reset),
        .Hsize(CPUDataSize),
        .Hwrite(CPUWriteEnable),
        .Hwritedata(CPUWriteData),
        .Haddress(CPUAddress),
        .Hreaddata(CPURomData),
        .Hresponse(Hresponse),
        .Hready(Hready),
        .Ram1OE(Ram1OE),
        .Ram1WE(Ram1WE),
        .Ram1EN(Ram1EN),
        .Ram1Address(Ram1Address),
        .Ram1data(Ram1data),
        .RxD(RxD),
        .TxD(TxD),
        .break(break),
        .CE0(CE0),
        .BYTE(BYTE),
        .VPEN(VPEN),
        .RP(RP),
        .OE(OE),
        .WE(WE),
        .flashAddress(flashAddress),
        .flashdata(flashdata),
        .hs(hs),
        .vs(vs),
        .r(r),
        .g(g),
        .b(b),
        .ps2clk(ps2clk),
        .ps2data(ps2data)
    );
endmodule
