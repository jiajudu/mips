`timescale 1ns / 1ps
module VirtualBus(
    input wire Hclock,
    input wire Hreset,
    input wire Hsize,
    input wire Hwrite,
    input wire[31:0] Hwritedata,
    input wire[31:0] Haddress,
    output reg[31:0] Hreaddata,
    output reg Hresponse,
    output reg Hready
);
    reg ready;
    //rom control
    reg Hselect_rom_temp;
    reg Hselect_rom;
    reg Hsize_rom;
    reg Hwrite_rom;
    reg[31:0] Hwritedata_rom;
    reg[8:0] Haddress_rom;
    wire[31:0] Hreaddata_rom;
    wire Hresponse_rom;
    wire Hready_rom;
    //VirtualSerial control
    reg Hselect_serial_temp;
    reg Hselect_serial;
    reg Hsize_serial;
    reg Hwrite_serial;
    reg[31:0] Hwritedata_serial;
    reg[2:0] Haddress_serial;
    wire[31:0] Hreaddata_serial;
    wire Hresponse_serial;
    wire Hready_serial;
    //Virtualsram control
    reg Hselect_sram_temp;
    reg Hselect_sram;
    reg Hsize_sram;
    reg Hwrite_sram;
    reg[31:0] Hwritedata_sram;
    reg[21:0] Haddress_sram;
    wire[31:0] Hreaddata_sram;
    wire Hresponse_sram;
    wire Hready_sram;
    //Virtualflash control
    reg Hselect_flash_temp;
    reg Hselect_flash;
    reg Hsize_flash;
    reg Hwrite_flash;
    reg[31:0] Hwritedata_flash;
    reg[23:0] Haddress_flash;
    wire[31:0] Hreaddata_flash;
    wire Hresponse_flash;
    wire Hready_flash;
    //no device
    reg Hselect_nodevice_temp;
    reg Hselect_nodevice;
    wire[3:0] countout_temp;
    //vsram
    wire Ram1OE;
    wire Ram1WE;
    wire Ram1EN;
    wire[19:0] Ram1Address;
    wire[31:0] Ram1data;
    always @(*) begin
        if(Hreset==1'b1) begin
            if(Haddress>=32'h1FC00000 && Haddress<=32'h1FC001FF) begin
                Hselect_nodevice_temp <= 1'b0;
                Hselect_rom_temp <= 1'b1;
                Hselect_serial_temp <= 1'b0;
                Hselect_sram_temp <= 1'b0;
                Hselect_flash_temp <= 1'b0;
                Hsize_rom <= Hsize;
                Hwrite_rom <= Hwrite;
                Hwritedata_rom <= Hwritedata;
                Haddress_rom <= Haddress[8:0];
            end else if(Haddress>=32'h1FD003F8 && Haddress<=32'h1FD003FF) begin
                Hselect_nodevice_temp <= 1'b0;
                Hselect_rom_temp <= 1'b0;
                Hselect_serial_temp <= 1'b1;
                Hselect_sram_temp <= 1'b0;
                Hselect_flash_temp <= 1'b0;
                Hsize_serial <= Hsize;
                Hwrite_serial <= Hwrite;
                Hwritedata_serial <= Hwritedata;
                Haddress_serial <= Haddress[2:0];
            end else if(Haddress>=32'h00000000 && Haddress<=32'h003fffff) begin
                Hselect_nodevice_temp <= 1'b0;
                Hselect_rom_temp <= 1'b0;
                Hselect_serial_temp <= 1'b0;
                Hselect_sram_temp <= 1'b1;
                Hselect_flash_temp <= 1'b0;
                Hsize_sram <= Hsize;
                Hwrite_sram <= Hwrite;
                Hwritedata_sram <= Hwritedata;
                Haddress_sram <= Haddress[19:0];
            end else if(Haddress>=32'h1e000000 && Haddress<=32'h1effffff) begin
                Hselect_nodevice_temp <= 1'b0;
                Hselect_rom_temp <= 1'b0;
                Hselect_serial_temp <= 1'b0;
                Hselect_sram_temp <= 1'b0;
                Hselect_flash_temp <= 1'b1;
                Hsize_flash <= Hsize;
                Hwrite_flash <= Hwrite;
                Hwritedata_flash <= Hwritedata;
                Haddress_flash <= Haddress[23:0];
            end else begin
                Hselect_nodevice_temp <= 1'b1;
                Hselect_rom_temp <= 1'b0;
                Hselect_serial_temp <= 1'b0;
                Hselect_sram_temp <= 1'b0;
                Hselect_flash_temp <= 1'b0;
                Hsize_rom <= 1'b0;
                Hwrite_rom <= 1'b0;
                Hwritedata_rom <= 32'b0;
                Haddress_rom <= 9'b0;
            end
        end else begin
            Hselect_nodevice_temp <= 1'b0;
            Hselect_rom_temp <= 1'b0;
            Hselect_serial_temp <= 1'b0;
            Hselect_sram_temp <= 1'b0;
            Hselect_flash_temp <= 1'b0;
        end
    end
    always @(*) begin
        if(Hreset==1'b1) begin
            if(Hselect_rom==1'b1) begin
                ready <= Hready_rom;
                Hresponse <= Hresponse_rom;
                Hreaddata <= Hreaddata_rom;
            end else if(Hselect_serial==1'b1) begin
                ready <= Hready_serial;
                Hresponse <= Hresponse_serial;
                Hreaddata <= Hreaddata_serial;
            end else if(Hselect_sram==1'b1) begin
                ready <= Hready_sram;
                Hresponse <= Hresponse_sram;
                Hreaddata <= Hreaddata_sram;
            end else if(Hselect_flash==1'b1) begin
                ready <= Hready_flash;
                Hresponse <= Hresponse_flash;
                Hreaddata <= Hreaddata_flash;
            end else if(Hselect_nodevice==1'b1) begin
                ready <= 1'b1;
                Hresponse <= 1'b1;
                Hreaddata <= 32'b0;
            end else begin
                ready <= 1'b1;
                Hresponse <= 1'b0;
                Hreaddata <= 32'b0;
            end
        end else begin
            ready <= 1'b1;
            Hresponse <= 1'b0;
            Hreaddata <= 32'b0;
        end
        Hready <= ready;
    end
    always @(posedge Hclock) begin
        if(ready==1'b1) begin
            Hselect_nodevice <= Hselect_nodevice_temp;
            Hselect_rom <= Hselect_rom_temp;
            Hselect_serial <= Hselect_serial_temp;
            Hselect_sram <= Hselect_sram_temp;
            Hselect_flash <= Hselect_flash_temp;
        end
    end
    VirtualRom VirtualRom0(
        .Hclock(Hclock),
        .Hreset(Hreset),
        .Hsize(Hsize_rom),
        .Hwrite(Hwrite_rom),
        .Hwritedata(Hwritedata_rom),
        .Haddress(Haddress_rom),
        .Hselect(Hselect_rom_temp),
        .ready(ready),
        .Hreaddata(Hreaddata_rom),
        .Hready(Hready_rom),
        .Hresponse(Hresponse_rom)
    );
    VirtualSerial VirtualSerial0(
        .Hclock(Hclock),
        .Hreset(Hreset),
        .Hsize(Hsize_serial),
        .Hwrite(Hwrite_serial),
        .Hwritedata(Hwritedata_serial),
        .Haddress(Haddress_serial),
        .Hselect(Hselect_serial_temp),
        .ready(ready),
        .Hreaddata(Hreaddata_serial),
        .Hready(Hready_serial),
        .Hresponse(Hresponse_serial)
    );
    VirtualSram Virtualsram0(
        .Hclock(Hclock),
        .Hreset(Hreset),
        .Hsize(Hsize_sram),
        .Hwrite(Hwrite_sram),
        .Hwritedata(Hwritedata_sram),
        .Haddress(Haddress_sram),
        .Hselect(Hselect_sram_temp),
        .ready(ready),
        .Hreaddata(Hreaddata_sram),
        .Hready(Hready_sram),
        .Hresponse(Hresponse_sram),
        .Ram1OE(Ram1OE),
        .Ram1WE(Ram1WE),
        .Ram1EN(Ram1EN),
        .Ram1Address(Ram1Address),
        .Ram1data(Ram1data)
    );
    vsram vsram0(
        .Ram1OE(Ram1OE),
        .Ram1WE(Ram1WE),
        .Ram1EN(Ram1EN),
        .Ram1Address(Ram1Address),
        .Ram1data(Ram1data)
    );
    VirtualFlash Virtualflash0(
        .Hclock(Hclock),
        .Hreset(Hreset),
        .Hsize(Hsize_flash),
        .Hwrite(Hwrite_flash),
        .Hwritedata(Hwritedata_flash),
        .Haddress(Haddress_flash),
        .Hselect(Hselect_flash_temp),
        .ready(ready),
        .Hreaddata(Hreaddata_flash),
        .Hready(Hready_flash),
        .Hresponse(Hresponse_flash)
    );
endmodule