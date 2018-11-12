module keyboard2ascii(
    input wire shift_flag,
    input wire[7:0] key,
    output wire[7:0] ascii
);
    reg[7:0] char;
    assign ascii=char;
    always@(*) begin
        if(shift_flag == 1'b1) begin
            case(key)
                8'h1C: char=8'h41; // A
                8'h32: char=8'h42; // B
                8'h21: char=8'h43; // C
                8'h23: char=8'h44; // D
                8'h24: char=8'h45; // E
                8'h2B: char=8'h46; // F
                8'h34: char=8'h47; // G
                8'h33: char=8'h48; // H
                8'h43: char=8'h49; // I
                8'h3B: char=8'h4A; // J
                8'h42: char=8'h4B; // K
                8'h4B: char=8'h4C; // L
                8'h3A: char=8'h4D; // M
                8'h31: char=8'h4E; // N
                8'h44: char=8'h4F; // O
                8'h4D: char=8'h50; // P
                8'h15: char=8'h51; // Q
                8'h2D: char=8'h52; // R
                8'h1B: char=8'h53; // S
                8'h2C: char=8'h54; // T
                8'h3C: char=8'h55; // U
                8'h2A: char=8'h56; // V
                8'h1D: char=8'h57; // W
                8'h22: char=8'h58; // X
                8'h35: char=8'h59; // Y
                8'h1A: char=8'h5A; // Z
                8'h29: char=8'h20; // Space
                8'h5A: char=8'h0A; // Enter
                8'h66: char=8'h08; // Back
                8'h49: char=8'h2e; // .
                // 0 ~ 9
                8'h45: char=8'h30; // 0
                8'h16: char=8'h31; // 1
                8'h1E: char=8'h32; // 2
                8'h26: char=8'h33; // 3
                8'h25: char=8'h34; // 4
                8'h2E: char=8'h35; // 5
                8'h36: char=8'h36; // 6
                8'h3D: char=8'h37; // 7
                8'h3E: char=8'h38; // 8
                8'h46: char=8'h39; // 9
                default: char = 8'h00;
            endcase
        end else begin
            case(key)
                8'h1C: char=8'h41 + 8'h20; // A
                8'h32: char=8'h42 + 8'h20; // B
                8'h21: char=8'h43 + 8'h20; // C
                8'h23: char=8'h44 + 8'h20; // D
                8'h24: char=8'h45 + 8'h20; // E
                8'h2B: char=8'h46 + 8'h20; // F
                8'h34: char=8'h47 + 8'h20; // G
                8'h33: char=8'h48 + 8'h20; // H
                8'h43: char=8'h49 + 8'h20; // I
                8'h3B: char=8'h4A + 8'h20; // J
                8'h42: char=8'h4B + 8'h20; // K
                8'h4B: char=8'h4C + 8'h20; // L
                8'h3A: char=8'h4D + 8'h20; // M
                8'h31: char=8'h4E + 8'h20; // N
                8'h44: char=8'h4F + 8'h20; // O
                8'h4D: char=8'h50 + 8'h20; // P
                8'h15: char=8'h51 + 8'h20; // Q
                8'h2D: char=8'h52 + 8'h20; // R
                8'h1B: char=8'h53 + 8'h20; // S
                8'h2C: char=8'h54 + 8'h20; // T
                8'h3C: char=8'h55 + 8'h20; // U
                8'h2A: char=8'h56 + 8'h20; // V
                8'h1D: char=8'h57 + 8'h20; // W
                8'h22: char=8'h58 + 8'h20; // X
                8'h35: char=8'h59 + 8'h20; // Y
                8'h1A: char=8'h5A + 8'h20; // Z
                8'h29: char=8'h20; // Space
                8'h5A: char=8'h0A; // Enter
                8'h66: char=8'h08; // Back
                8'h49: char=8'h2e; // .
                // 0 ~ 9
                8'h45: char=8'h30; // 0
                8'h16: char=8'h31; // 1
                8'h1E: char=8'h32; // 2
                8'h26: char=8'h33; // 3
                8'h25: char=8'h34; // 4
                8'h2E: char=8'h35; // 5
                8'h36: char=8'h36; // 6
                8'h3D: char=8'h37; // 7
                8'h3E: char=8'h38; // 8
                8'h46: char=8'h39; // 9
                default: char = 8'h00;
            endcase
        end
    end
endmodule