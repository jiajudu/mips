module flash(
    input wire Hclock,
    input wire Hreset,
    input wire[22:0] Haddress,
    input wire Hselect,
    input wire ready,
    output reg CE0,
    output reg BYTE,
    output reg VPEN,
    output reg RP,
    output reg OE,
    output reg WE,
    output reg[22:0] addr,
    inout wire[15:0] data,
    output reg[15:0] Hreaddata,
    output reg Hready,
    output reg Hresponse
);
    reg[15:0] data_temp;
    reg[22:0] Haddress_temp;
    reg control;
    reg[3:0] state;
    reg[2:0] count;
    assign data[15:0] = (control == 1)?data_temp[15:0]:{16{1'bz}};
    localparam READ_1 = 4'd1, READ_2 = 4'd2, READ_3 = 4'd3, READ_4 = 4'd4, READ_5 = 4'd5;
    localparam IDLE = 4'd15;
    always@(posedge Hclock or negedge Hreset) begin
        if(Hreset == 0) begin
            state <= IDLE;
            count <= 2'b0;
        end else begin
            if(Hready == 1 && ready == 1) begin
                count <= 2'b0;
                Haddress_temp <= Haddress;
                if(Hselect == 1) begin
                    state <= READ_1;
                end else begin
                    state <= IDLE;
                end
            end else begin
                Haddress_temp <= Haddress_temp;
                case(state)
                    READ_1: begin
                        state <= READ_2;
                        count <= 2'b0;
                    end
                    READ_2: begin
                        state <= READ_3;
                        count <= 2'b0;
                    end
                    READ_3: begin
                        state <= READ_4;
                        count <= 2'b0;
                    end
                    READ_4: begin
                        Hreaddata <= data[15:0];
                        if(count == 2'b11) begin
                            state <= READ_5;
                            count <= 2'b0;
                        end else begin
                            state <= READ_4;
                            count <= (count + 1'b1) & {3{1'b1}};
                        end
                    end
                    READ_5: begin
                        state <= IDLE;
                        count <= 2'b0;
                    end
                    default: begin
                        state <= IDLE;
                        count <= 2'b0;
                    end
                endcase
            end
        end
    end
    always@(*) begin
        if(Hreset == 0) begin
            WE <= 1'b1;
            OE <= 1'b1;
            VPEN <= 1'b1;
            RP <= 1'b1;
            BYTE <= 1'b1;
            control <= 1;
            data_temp <=16'h00FF;
            addr <= 23'b0;
            CE0 <= 1'b0;
            Hresponse <= 1'b0;
            Hready <= 1'b1;
        end else begin
            CE0 <= 1'b0;
            Hresponse <= 1'b0;
            case(state)
                READ_1: begin
                    WE <= 1'b0;
                    OE <= 1'b1;
                    VPEN <= 1'b1;
                    RP <= 1'b1;
                    BYTE <= 1'b1;
                    control <= 1'b1;
                    data_temp <=16'h00FF;
                    addr <= 23'b0;
                    Hready <= 1'b0;
                end
                READ_2: begin
                    WE <= 1'b1;
                    OE <= 1'b1;
                    VPEN <= 1'b1;
                    RP <= 1'b1;
                    BYTE <= 1'b1;
                    control <= 1'b1;
                    data_temp <=16'h00FF;
                    addr <= 23'b0;
                    Hready <= 1'b0;
                end
                READ_3: begin
                    WE <= 1'b1;
                    OE <= 1'b0;
                    VPEN <= 1'b1;
                    RP <= 1'b1;
                    BYTE <= 1'b1;
                    control <= 1'b1;
                    data_temp <=16'h00FF;
                    addr <= 23'b0;
                    Hready <= 1'b0;
                end
                READ_4: begin
                    WE <= 1'b1;
                    OE <= 1'b0;
                    VPEN <= 1'b1;
                    RP <= 1'b1;
                    BYTE <= 1'b1;
                    control <= 1'b0;
                    data_temp <=16'h0000;
                    addr <= Haddress_temp;
                    Hready <= 1'b0;
                end
                READ_5: begin
                    WE <= 1'b1;
                    OE <= 1'b1;
                    VPEN <= 1'b1;
                    RP <= 1'b1;
                    BYTE <= 1'b1;
                    control <= 1'b0;
                    data_temp <=16'h0000;
                    addr <= 23'b0;
                    Hready <= 1'b1;
                end
                default: begin
                    WE <= 1'b1;
                    OE <= 1'b1;
                    VPEN <= 1'b1;
                    RP <= 1'b1;
                    BYTE <= 1'b1;
                    control <= 0;
                    data_temp <=16'h0000;
                    addr <= 23'b0;
                    Hready <= 1'b1;
                end
            endcase
        end
    end
endmodule