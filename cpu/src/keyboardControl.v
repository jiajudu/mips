module keyboardControl(
    input wire Hclock,
    input wire Hreset,
    input wire ps2data,
    input wire ps2clk,
    output wire Hready,
    output reg[7:0] data
);
    reg[3:0] state;
    reg[7:0] temp_data;
    reg ps2ready;
    wire[7:0] ascii;
    wire shift_flag;
    wire[7:0] datain;
    wire ready;
    assign shift_flag = ((state == SHIFT) | (state == SHIFTKEY) | (state == SHIFTRELEASE));
    localparam IDLE = 4'd0, KEY1 = 4'd1, KEY2 = 4'd2;
    localparam SHIFT = 4'd3, SHIFTKEY = 4'd4, SHIFTRELEASE = 4'd5;
    assign Hready = ps2ready & (data != 8'b0);
    keyboard2ascii keyboard2ascii0(.shift_flag(shift_flag), .key(datain), .ascii(ascii));
    ps2 ps20(.Hclock(Hclock), .Hreset(Hreset), .receiveData(datain), .Hready(ready), .ps2data(ps2data), .ps2clk(ps2clk));
    always@(posedge Hclock) begin
        if(Hreset == 1'b0) begin
            ps2ready <= 1'b0;
            data <= 8'b0;
            temp_data <= 8'b0;
            state <= IDLE;
        end else begin
            case(state)
                IDLE: begin
                    if(ready == 1'b1) begin
                        if(datain == 8'h12) begin  // L Shift
                            state <= SHIFT;
                            ps2ready <= 1'b0;
                            data <= 8'b0;
                        end else if(ascii != 8'h0) begin  // correct char
                            state <= KEY1;
                            ps2ready <= 1'b1;
                            data <= ascii;
                        end else begin
                            state <= IDLE;
                            ps2ready <= 1'b0;
                            data <= 8'b0;
                        end
                    end else begin
                        state <= IDLE;
                        ps2ready <= 1'b0;
                        data <= 8'b0;					
                    end
                end
                KEY1: begin
                    if(ready == 1'b1) begin
                        if(datain == 8'hF0) begin // break
                            state <= KEY2;
                            ps2ready <= 1'b0;
                            data <= 8'b0;
                        end else if(ascii != 8'b0) begin
                            state <= KEY1;
                            ps2ready <= 1'b1;
                            data <= ascii;												
                        end else begin // error
                            state <= IDLE;
                        end
                    end else begin
                        state <= state;
                        ps2ready <= 1'b0;
                        data <= 8'b0;
                    end
                end
                KEY2: begin
                    if(ready == 1'b1) begin
                        state <= IDLE;
                        ps2ready <= 1'b0;
                        data <= 8'b0;
                    end else begin
                        state <= state;
                        ps2ready <= 1'b0;
                        data <= 8'b0;
                    end
                end
                SHIFT: begin
                    if(ready == 1'b1) begin
                        if(datain == 8'hF0) begin
                            state <= KEY2;
                            ps2ready <= 1'b0;
                            data <= 8'b0;
                        end else if(ascii != 8'h0) begin
                            state <= SHIFTKEY;
                            ps2ready <= 1'b1;
                            data <= ascii;
                        end else begin
                            state <= state;
                            ps2ready <= 1'b0;
                            data <= 8'b0;
                        end
                    end else begin
                        state <= state;
                        ps2ready <= 1'b0;
                        data <= 8'b0;
                    end
                end
                SHIFTKEY: begin
                    if(ready == 1'b1) begin
                        if(datain == 8'hF0) begin
                            state <= SHIFTRELEASE;
                            ps2ready <= 1'b0;
                            data <= 8'b0;
                        end else if(ascii != 8'h0) begin
                            state <= state;
                            ps2ready <= 1'b1;
                            data <= ascii;
                        end else begin
                            state <= state;
                            ps2ready <= 1'b0;
                            data <= 8'b0;
                        end
                    end else begin
                        state <= state;
                        ps2ready <= 1'b0;
                        data <= 8'b0;
                    end
                end
                SHIFTRELEASE: begin
                    if(ready == 1'b1) begin
                        if(datain == 8'h12) begin // release l shift
                            state <= KEY1;
                            ps2ready <=1'b0;
                            data <= 8'b0;
                        end else if(ascii !=0 )begin
                            state <= SHIFT;
                            ps2ready <= 1'b0;
                            data <= 8'b0;
                        end else begin          // error
                            state <= IDLE;
                            ps2ready <= 1'b0;
                            data <= 8'b0;
                        end
                    end else begin
                        state <= state;
                        ps2ready <= 1'b0;
                        data <= 8'b0;
                    end
                end
                default: begin
                    state <= state;
                    ps2ready <= 1'b0;
                    data <= 8'b0;				
                end
            endcase
        end
    end
endmodule