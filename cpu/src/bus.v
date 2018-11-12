`timescale 1ns / 1ps
module bus(
    input wire Hclock,
    input wire Hreset,
    input wire Hsize,
    input wire Hwrite,
    input wire[31:0] Hwritedata,
    input wire[31:0] Haddress,
    output reg[31:0] Hreaddata,
    output reg Hresponse,
    output reg Hready,
    output wire Ram1OE,
    output wire Ram1WE,
    output wire Ram1EN,
    output wire[19:0] Ram1Address,
    inout wire[31:0] Ram1data,
    input wire RxD,
    output wire TxD,
    output wire break,
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
    //Serial control
    reg Hselect_serial_temp;
    reg Hselect_serial;
    reg Hwrite_serial;
    reg[7:0] Hwritedata_serial;
    reg[2:0] Haddress_serial;
    wire[7:0] Hreaddata_serial;
    wire Hresponse_serial;
    wire Hready_serial;
    //sram control
    reg Hselect_sram_temp;
    reg Hselect_sram;
    reg Hsize_sram;
    reg Hwrite_sram;
    reg[31:0] Hwritedata_sram;
    reg[21:0] Haddress_sram;
    wire[31:0] Hreaddata_sram;
    wire Hresponse_sram;
    wire Hready_sram;
    //vga control
    reg Hselect_vga_temp;
    reg Hselect_vga;
    reg Hsize_vga;
    reg Hwrite_vga;
    reg[31:0] Hwritedata_vga;
    reg[11:0] Haddress_vga;
    wire[31:0] Hreaddata_vga;
    wire Hresponse_vga;
    wire Hready_vga;
    //flash control
    reg Hselect_flash_temp;
    reg Hselect_flash;
    reg[22:0] Haddress_flash;
    wire[15:0] Hreaddata_flash;
    wire Hresponse_flash;
    wire Hready_flash;
    //no device
    reg Hselect_nodevice_temp;
    reg Hselect_nodevice;
    wire[3:0] countout_temp;
    always @(*) begin
        if(Hreset==1'b1) begin
            if(Haddress>=32'h1FC00000 && Haddress<=32'h1FC001FF) begin
                Hselect_nodevice_temp <= 1'b0;
                Hselect_rom_temp <= 1'b1;
                Hselect_serial_temp <= 1'b0;
                Hselect_sram_temp <= 1'b0;
                Hselect_flash_temp <= 1'b0;
                Hselect_vga_temp <= 1'b0;
                Hsize_rom <= Hsize;
                Hwrite_rom <= Hwrite;
                Hwritedata_rom <= Hwritedata;
                Haddress_rom <= Haddress[8:0];
                Hwrite_serial <= 1'b0;
                Hwritedata_serial <= 8'b0;
                Haddress_serial <= 3'b0;
                Hsize_sram <= 1'b0;
                Hwrite_sram <= 1'b0;
                Hwritedata_sram <= 32'b0;
                Haddress_sram <= 20'b0;
                Hsize_vga <= 1'b0;
                Hwrite_vga <= 1'b0;
                Hwritedata_vga <= 32'b0;
                Haddress_vga <= 12'b0;
                Haddress_flash <= 23'b0;
            end else if(Haddress>=32'h1FD003F8 && Haddress<=32'h1FD003FF) begin
                Hselect_nodevice_temp <= 1'b0;
                Hselect_rom_temp <= 1'b0;
                Hselect_serial_temp <= 1'b1;
                Hselect_sram_temp <= 1'b0;
                Hselect_flash_temp <= 1'b0;
                Hselect_vga_temp <= 1'b0;
                Hwrite_serial <= Hwrite;
                Hwritedata_serial <= Hwritedata[7:0];
                Haddress_serial <= Haddress[2:0];
                Hsize_rom <= 1'b0;
                Hwrite_rom <= 1'b0;
                Hwritedata_rom <= 32'b0;
                Haddress_rom <= 9'b0;
                Hsize_sram <= 1'b0;
                Hwrite_sram <= 1'b0;
                Hwritedata_sram <= 32'b0;
                Haddress_sram <= 20'b0;
                Hsize_vga <= 1'b0;
                Hwrite_vga <= 1'b0;
                Hwritedata_vga <= 32'b0;
                Haddress_vga <= 12'b0;
                Haddress_flash <= 23'b0;
            end else if(Haddress>=32'h00000000 && Haddress<=32'h003fffff) begin
                Hselect_nodevice_temp <= 1'b0;
                Hselect_rom_temp <= 1'b0;
                Hselect_serial_temp <= 1'b0;
                Hselect_sram_temp <= 1'b1;
                Hselect_flash_temp <= 1'b0;
                Hselect_vga_temp <= 1'b0;
                Hsize_sram <= Hsize;
                Hwrite_sram <= Hwrite;
                Hwritedata_sram <= Hwritedata;
                Haddress_sram <= Haddress[21:0];
                Hsize_rom <= 1'b0;
                Hwrite_rom <= 1'b0;
                Hwritedata_rom <= 32'b0;
                Haddress_rom <= 9'b0;
                Hwrite_serial <= 1'b0;
                Hwritedata_serial <= 8'b0;
                Haddress_serial <= 3'b0;
                Hsize_vga <= 1'b0;
                Hwrite_vga <= 1'b0;
                Hwritedata_vga <= 32'b0;
                Haddress_vga <= 12'b0;
                Haddress_flash <= 23'b0;
            end else if(Haddress>=32'h1e000000 && Haddress<=32'h1effffff) begin
                Hselect_nodevice_temp <= 1'b0;
                Hselect_rom_temp <= 1'b0;
                Hselect_serial_temp <= 1'b0;
                Hselect_sram_temp <= 1'b0;
                Hselect_flash_temp <= 1'b1;
                Hselect_vga_temp <= 1'b0;
                Haddress_flash <= Haddress[23:1] + 2'b10;
                Hsize_rom <= 1'b0;
                Hwrite_rom <= 1'b0;
                Hwritedata_rom <= 32'b0;
                Haddress_rom <= 9'b0;
                Hwrite_serial <= 1'b0;
                Hwritedata_serial <= 8'b0;
                Haddress_serial <= 3'b0;
                Hsize_sram <= 1'b0;
                Hwrite_sram <= 1'b0;
                Hwritedata_sram <= 32'b0;
                Haddress_sram <= 20'b0;
                Hsize_vga <= 1'b0;
                Hwrite_vga <= 1'b0;
                Hwritedata_vga <= 32'b0;
                Haddress_vga <= 12'b0;
            end else if(Haddress>=32'h10000000 && Haddress<=32'h10001000) begin
                Hselect_nodevice_temp <= 1'b0;
                Hselect_rom_temp <= 1'b0;
                Hselect_serial_temp <= 1'b0;
                Hselect_sram_temp <= 1'b0;
                Hselect_flash_temp <= 1'b0;
                Hselect_vga_temp <= 1'b1;
                Haddress_flash <= 23'b0;
                Hsize_rom <= 1'b0;
                Hwrite_rom <= 1'b0;
                Hwritedata_rom <= 32'b0;
                Haddress_rom <= 9'b0;
                Hwrite_serial <= 1'b0;
                Hwritedata_serial <= 8'b0;
                Haddress_serial <= 3'b0;
                Hsize_sram <= 1'b0;
                Hwrite_sram <= 1'b0;
                Hwritedata_sram <= 32'b0;
                Haddress_sram <= 20'b0;
                Hsize_vga <= Hsize;
                Hwrite_vga <= Hwrite;
                Hwritedata_vga <= Hwritedata;
                Haddress_vga <= Haddress[11:0];
            end else begin
                Hselect_nodevice_temp <= 1'b1;
                Hselect_rom_temp <= 1'b0;
                Hselect_serial_temp <= 1'b0;
                Hselect_sram_temp <= 1'b0;
                Hselect_flash_temp <= 1'b0;
                Hselect_vga_temp <= 1'b0;
                Hsize_rom <= 1'b0;
                Hwrite_rom <= 1'b0;
                Hwritedata_rom <= 32'b0;
                Haddress_rom <= 9'b0;
                Hwrite_serial <= 1'b0;
                Hwritedata_serial <= 8'b0;
                Haddress_serial <= 3'b0;
                Hsize_sram <= 1'b0;
                Hwrite_sram <= 1'b0;
                Hwritedata_sram <= 32'b0;
                Haddress_sram <= 20'b0;
                Hsize_vga <= 1'b0;
                Hwrite_vga <= 1'b0;
                Hwritedata_vga <= 32'b0;
                Haddress_vga <= 12'b0;
                Haddress_flash <= 23'b0;
            end
        end else begin
            Hselect_nodevice_temp <= 1'b0;
            Hselect_rom_temp <= 1'b0;
            Hselect_serial_temp <= 1'b0;
            Hselect_sram_temp <= 1'b0;
            Hselect_flash_temp <= 1'b0;
            Hselect_vga_temp <= 1'b0;
            Hsize_rom <= 1'b0;
            Hwrite_rom <= 1'b0;
            Hwritedata_rom <= 32'b0;
            Haddress_rom <= 9'b0;
            Hwrite_serial <= 1'b0;
            Hwritedata_serial <= 8'b0;
            Haddress_serial <= 3'b0;
            Hsize_sram <= 1'b0;
            Hwrite_sram <= 1'b0;
            Hwritedata_sram <= 32'b0;
            Haddress_sram <= 20'b0;
            Hsize_vga <= 1'b0;
            Hwrite_vga <= 1'b0;
            Hwritedata_vga <= 32'b0;
            Haddress_vga <= 12'b0;
            Haddress_flash <= 23'b0;
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
                Hreaddata <= {24'b0, Hreaddata_serial};
            end else if(Hselect_sram==1'b1) begin
                ready <= Hready_sram;
                Hresponse <= Hresponse_sram;
                Hreaddata <= Hreaddata_sram;
            end else if(Hselect_flash==1'b1) begin
                ready <= Hready_flash;
                Hresponse <= Hresponse_flash;
                Hreaddata <= {16'b0, Hreaddata_flash};
            end else if(Hselect_vga==1'b1) begin
                ready <= Hready_vga;
                Hresponse <= Hresponse_vga;
                Hreaddata <= Hreaddata_vga;
            end else if(Hselect_nodevice==1'b1) begin
                ready <= 1'b1;
                Hresponse <= 1'b1;//error
                Hreaddata <= 32'b0;
            end else begin
                ready <= 1'b1;
                Hresponse <= 1'b0;//error
                Hreaddata <= 32'b0;
            end
        end else begin
            ready <= 1'b1;
            Hresponse <= 1'b0;//error
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
            Hselect_vga <= Hselect_vga_temp;
        end
    end
    rom rom0(
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
    serial_port serial_port0(
        .Hclock(Hclock),
        .Hreset(Hreset),
        .Hwritedata(Hwritedata_serial),
        .Haddress(Haddress_serial),
        .Hselect(Hselect_serial_temp),
        .Hwrite(Hwrite_serial),
        .ready(ready),
        .receiveData(Hreaddata_serial),
        .Hready(Hready_serial),
        .Hresponse(Hresponse_serial),
        .break(break),
        .TxD(TxD),
        .RxD(RxD),
        .ps2clk(ps2clk),
        .ps2data(ps2data)
    );
    sram sram0(
        .Hclock(Hclock),
        .Hreset(Hreset),
        .Ram1OE(Ram1OE),
        .Ram1WE(Ram1WE),
        .Ram1EN(Ram1EN),
        .Hsize(Hsize_sram),
        .Hwrite(Hwrite_sram),
        .Hwritedata(Hwritedata_sram),
        .Haddress(Haddress_sram),
        .Hselect(Hselect_sram_temp),
        .ready(ready),
        .Hreaddata(Hreaddata_sram),
        .Hready(Hready_sram),
        .Hresponse(Hresponse_sram),
        .Ram1Address(Ram1Address),
        .Ram1data(Ram1data)
    );
    flash flash0(
        .Hclock(Hclock),
        .Hreset(Hreset),
        .Haddress(Haddress_flash),
        .Hselect(Hselect_flash_temp),
        .ready(ready),
        .CE0(CE0),
        .BYTE(BYTE),
        .VPEN(VPEN),
        .RP(RP),
        .OE(OE),
        .WE(WE),
        .addr(flashAddress),
        .data(flashdata),
        .Hreaddata(Hreaddata_flash),
        .Hready(Hready_flash),
        .Hresponse(Hresponse_flash)
    );
    vga vga0(
        .Hclock(Hclock),
        .Hreset(Hreset),
        .Hselect(Hselect_vga_temp),
        .Hwrite(Hwrite_vga),
        .Hsize(Hsize_vga),
        .ready(ready),
        .Hwritedata(Hwritedata_vga),
        .Haddress(Haddress_vga),
        .Hreaddata(Hreaddata_vga),
        .Hready(Hready_vga),
    	.Hresponse(Hresponse_vga),
        .vs(vs),
        .hs(hs),
        .r(r),
        .g(g),
        .b(b)
    );
endmodule