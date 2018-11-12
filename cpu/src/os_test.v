`timescale 1ns / 1ps
module os_test;
    reg clock;
    reg reset;
    reg CPUSerialInterrupt;
    wire[31:0] CPURomData;
    wire[31:0] CPUAddress;
    wire CPUWriteEnable;
    wire CPUDataSize;
    wire[31:0] CPUWriteData;
    wire Hresponse;
    wire Hready;
    initial begin
        clock = 1'b1;
        forever #40 clock = ~clock;
    end
    initial begin
        reset = 1'b0;
        #5 reset = 1'b1;
    end
    initial begin
        CPUSerialInterrupt = 1'b0;
    end
    cpu uut(
        .clock(clock),
        .reset(reset),
        .CPUBusReady(Hready),
        .CPURomData(CPURomData),
        .CPUBusResponse(Hresponse),
        .CPUSerialInterrupt(CPUSerialInterrupt),
        .CPUAddress(CPUAddress),
        .CPUWriteEnable(CPUWriteEnable),
        .CPUDataSize(CPUDataSize),
        .CPUWriteData(CPUWriteData)
    );
    VirtualBus VirtualBus0(
        .Hclock(clock),
        .Hreset(reset),
        .Hsize(CPUDataSize),
        .Hwrite(CPUWriteEnable),
        .Hwritedata(CPUWriteData),
        .Haddress(CPUAddress),
        .Hreaddata(CPURomData),
        .Hresponse(Hresponse),
        .Hready(Hready)
    );
endmodule
