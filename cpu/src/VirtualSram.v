`timescale 1ns / 1ps
module VirtualSram(
	//common interfaces
	input wire Hclock,
	input wire Hreset,
	output reg Ram1OE,
	output reg Ram1WE,
	output reg Ram1EN,
	output reg[19:0] Ram1Address,
	inout wire[31:0] Ram1data,
	//sram interfaces
	input wire Hselect,
	input wire Hwrite,
	input wire Hsize,
	input wire ready,
	input wire[31:0] Hwritedata,
	input wire[21:0] Haddress,
	output reg[31:0] Hreaddata,
	output Hready,
	output reg Hresponse
	);
	reg[31:0] data_temp;
	reg[3:0] state;
	reg[31:0] Hwritedata_temp;
	reg[21:0] Haddress_temp;
	reg control;
	assign Hready = (state != WriteByte1) & ((state != WriteByte2) & (state != WriteWord1) & (state != WriteWord2) & (state != WriteByte3));
	assign Ram1data = (control == 1'b1)?data_temp:{32{1'bz}};
	localparam WriteWord1 = 4'd1, WriteByte1 = 4'd2, WriteByte2 = 4'd3, ReadWord  = 4'd4, ReadByte = 4'd5, idle = 4'd7;
	localparam WriteWord2 = 4'd8, WriteByte3 = 4'd9, WriteWord3 = 4'd10, WriteByte4 = 4'd11;
    always @(posedge Hclock or negedge Hreset) begin
		if (Hreset == 0) begin
			state <= idle;
			Haddress_temp <= 20'b0;
			Hwritedata_temp <= 32'b0;
		end else if(Hselect == 1 && ready == 1) begin
			Haddress_temp <= Haddress;
			Hwritedata_temp <= Hwritedata;
			if(Hwrite == 1'b1) begin
				if(Hsize == 1'b1) begin
					state <= WriteWord1;
				end else begin
					state <= WriteByte1;
				end
			end else begin
				if(Hsize == 1'b1) begin
					state <= ReadWord;
				end else begin
					state <= ReadByte;
				end
			end
		end else if(state == WriteByte1) begin
			state <= WriteByte2;
			Haddress_temp <= Haddress_temp;
			case(Haddress_temp[1:0])
				2'b00: Hwritedata_temp <= {Hreaddata[31:8], Hwritedata_temp[7:0]} ;
				2'b01: Hwritedata_temp <= {Hreaddata[31:16], Hwritedata_temp[7:0], Hreaddata[7:0]} ;
				2'b10: Hwritedata_temp <= {Hreaddata[31:24], Hwritedata_temp[7:0], Hreaddata[15:0]} ;
				default: Hwritedata_temp <= {Hwritedata_temp[7:0], Hreaddata[23:0]} ;
			endcase
        end else if(state == WriteByte2) begin
  			state <= WriteByte3;
			Haddress_temp <= Haddress_temp;
			Hwritedata_temp <= Hwritedata_temp;     
        end else if(state == WriteByte3) begin
  			state <= WriteByte4;
			Haddress_temp <= Haddress_temp;
			Hwritedata_temp <= Hwritedata_temp;      
        end else if(state == WriteWord1) begin
            state <= WriteWord2;
			Haddress_temp <= Haddress_temp;
			Hwritedata_temp <= Hwritedata_temp;
        end else if(state == WriteWord2) begin
            state <= WriteWord3;
			Haddress_temp <= Haddress_temp;
			Hwritedata_temp <= Hwritedata_temp;
        end else begin
			Haddress_temp <= Haddress;
			Hwritedata_temp <= Hwritedata;
			state <= idle;
		end
	end
	always @(*) begin
		if (Hreset == 1'b0) begin
			Hreaddata = 32'b0;
			Ram1OE = 1'b1;
			Ram1WE = 1'b1;
			Ram1EN = 1'b1;
			data_temp = 32'b0;
			control = 1'b1;
			Ram1Address = 20'b0;
            //Hready = 1'b1;
            Hresponse = 1'b0;
		end else begin
			
			case(state)
				WriteWord1: begin
                    Ram1Address = Haddress_temp[21:2];
					control = 1'b1;
					data_temp = Hwritedata_temp;
					Ram1WE = 1'b1;
					Ram1OE = 1'b1;
					Ram1EN = 1'b1;
					Hreaddata = 32'b0;
					Hresponse = 0;
				end
				WriteWord2: begin
                    Ram1Address = Haddress_temp[21:2];
					control = 1'b1;
					data_temp = Hwritedata_temp;
					Ram1WE = 1'b0;
					Ram1OE = 1'b1;
					Ram1EN = 1'b0;
					Hreaddata = 32'b0;
					Hresponse = 0;				  	
				end
				WriteWord3: begin
                    Ram1Address = Haddress_temp[21:2];
					control = 1'b1;
					data_temp = Hwritedata_temp;
					Ram1WE = 1'b1;
					Ram1OE = 1'b1;
					Ram1EN = 1'b1;
					Hreaddata = 32'b0;
					Hresponse = 0;				  	
				end
				ReadWord: begin
					control = 1'b0;
					Ram1WE = 1'b1;
					Ram1OE = 1'b0;
					Ram1EN = 1'b0;
					data_temp = 32'b0;
                    Ram1Address = Haddress_temp[21:2];
					Hreaddata = Ram1data;
					Hresponse = 0;		
				end
				ReadByte: begin
					control = 1'b0;
					Ram1WE = 1'b1;
					Ram1OE = 1'b0;
					Ram1EN = 1'b0;
					data_temp = 32'b0;
                    Ram1Address = Haddress_temp[21:2];
					case(Haddress_temp[1:0])
						2'b00: Hreaddata = {24'b0,Ram1data[7:0]};
						2'b01: Hreaddata = {24'b0,Ram1data[15:8]};
						2'b10: Hreaddata = {24'b0,Ram1data[23:16]};
						default: Hreaddata = {24'b0,Ram1data[31:24]};
					endcase
					Hresponse = 0;		
				end
				WriteByte1: begin
                    Ram1Address = Haddress_temp[21:2];
					control = 1'b0;
					Ram1WE = 1'b1;
					Ram1OE = 1'b0;
					Ram1EN = 1'b0;
					data_temp = 32'b0;
					Hreaddata = Ram1data;
					Hresponse = 0;
				end
				WriteByte2: begin
                    Ram1Address = Haddress_temp[21:2];
					control=1'b1;
					Ram1WE = 1'b1;
					Ram1OE = 1'b1;
					Ram1EN = 1'b1;
					data_temp = Hwritedata_temp;
					Hreaddata = 32'b0;
					Hresponse = 0;
				end

				WriteByte3: begin
                    Ram1Address = Haddress_temp[21:2];
					control=1'b1;
					Ram1WE = 1'b0;
					Ram1OE = 1'b1;
					Ram1EN = 1'b0;
					data_temp = Hwritedata_temp;
					Hreaddata = 32'b0;
					Hresponse = 0;
				end

				WriteByte4: begin
                    Ram1Address = Haddress_temp[21:2];
					control = 1'b1;
					Ram1WE = 1'b1;
					Ram1OE = 1'b1;
					Ram1EN = 1'b1;
					data_temp = Hwritedata_temp;
					Hreaddata = 32'b0;
					Hresponse = 0;
				end

				default: begin
                    Ram1Address = Haddress_temp[21:2];
					control=1'b0;
					Ram1WE = 1'b1;
					Ram1OE = 1'b1;
					Ram1EN = 1'b1;
					data_temp = 32'b0;
					Hresponse = 0;
					Hreaddata = 32'b0;
				end
			endcase
		end
	end
endmodule
