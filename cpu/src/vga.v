module vga(
    input wire Hclock,
    input wire Hreset,
    input wire Hselect,
    input wire Hwrite,
    input wire Hsize,
    input wire ready,
    input wire[31:0] Hwritedata,
    input wire[11:0] Haddress,
    output reg[31:0] Hreaddata,
    output reg Hready,
    output reg Hresponse,
    output reg vs,
    output reg hs,
    output reg[2:0] r,
    output reg[2:0] g,
    output reg[2:0] b
);
    reg[9:0] vector_x;
    reg[9:0] vector_y;
    reg[9:0] next_x;
    reg[9:0] next_y;
    reg hs1;
    reg vs1;
    reg[2:0] r1;
    reg[2:0] g1;
    reg[2:0] b1;
    reg[7:0] data[0:2400];
    reg[6:0] char;
    reg[6:0] char_pixel_pos;
    reg[11:0] current_pos;
    wire mask;
    always @(posedge Hclock) begin
        if(Hreset == 1'b0) begin
            Hreaddata <= 32'b0;
            Hready <= 1'b1;
            Hresponse <= 1'b0;
        end else begin
            Hreaddata <= 32'b0;
            Hready <= 1'b1;
            Hresponse <= 1'b0;
            if(Hselect == 1'b1 && ready == 1'b1 && Haddress < 12'd2400 && Hwrite == 1'b1 && Hsize == 1'b0) begin
                data[Haddress] <= Hwritedata[7:0];
            end
        end
    end
    always @(posedge Hclock) begin
        if (Hreset == 1'b0) begin
            vector_x <= 10'd0;
            vector_y <= 10'd0;
            hs <= 1'b0;
            vs <= 1'b0;
            r <= 3'b000;
            g <= 3'b000;
            b <= 3'b000;
        end else begin
            vector_x <= next_x;
            vector_y <= next_y;
            hs <= hs1;
            vs <= vs1;
            r <= r1;
            g <= g1;
            b <= b1;
        end
    end
    always @(*) begin
        if (vector_x == 10'd799) begin
            next_x = 0;
            if (vector_y == 10'd524) begin
                next_y = 0;
            end else begin
                next_y = vector_y + 1;
            end
        end else begin
            next_y = vector_y;
            next_x = vector_x + 1;
        end
    end
    always @(*) begin
        if (vector_x >= 10'd655 && vector_x < 10'd751)
            hs1 = 0;
        else hs1 = 1;
        if (vector_y >= 10'd489 && vector_y < 10'd491)
            vs1 = 0;
        else vs1 = 1;
    end
    always @(*) begin
        if(vector_x < 640 && vector_y < 480) begin
            current_pos <= vector_y[9:4] * 7'd80 + vector_x[9:3];
        end else begin
            current_pos <= 12'd2400;
        end
        char = data[current_pos][6:0];
        char_pixel_pos = {vector_y[3:0], vector_x[2:0]};
    end
    always @(*) begin
        if (mask == 1 && vs1 == 1 && hs1 == 1) begin
            r1 = 3'b111;
            g1 = 3'b111;
            b1 = 3'b111;
        end else begin
            r1 = 3'b000;
            g1 = 3'b000;
            b1 = 3'b000;
        end
    end
    vga_rom vga_rom0(.ch(char), .pos(char_pixel_pos), .mask(mask));
endmodule