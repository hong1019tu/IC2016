
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
input gray_ready;
input [7:0] gray_data;
output reg [13:0] gray_addr;
output reg     	  gray_req;
output reg [13:0] lbp_addr;
output reg lbp_valid;
output reg [7:0] lbp_data;
output reg 	finish;
reg [7:0] x,y;
reg [7:0] x1,y1;
reg [8:0]data[8:0];
reg [1:0]state;//0 :egde 1 : x = 1(load 9 num) 2 : else 3 : xy change
reg [3:0]load;
always @(posedge clk or posedge reset) begin
    if(reset) begin
        lbp_valid <= 1'd0;
        finish <= 1'd0;
        x <= 8'd0;
        y <= 8'd1;
        state <= 2'd3;
        load <= 4'd0;
    end
    else begin
        gray_req <= 1'd1;//check
        case (state)
        2'd1:begin//x = 1
            load <= load + 4'd1;
            case(load)
            4'd0:begin
                lbp_data[6] <= data[7] >= data[4] ? 1'b1:1'b0;
                lbp_data[7] <= data[8] >= data[4] ? 1'b1:1'b0;
                gray_addr <= (x1-1) + ((y1-1) << 7);
            end
            4'd1:begin
                gray_addr <= (x1) + ((y1-1) <<7);
                data[0] <= gray_data;
            end
            4'd2:begin
                gray_addr <= (x1+1) + ((y1-1) <<7);
                data[1] <= gray_data;
            end
            4'd3:begin
                gray_addr <= (x1-1) + ((y1) <<7);
                data[2] <= gray_data;
            end
            4'd4:begin
                gray_addr <= (x1) + ((y1) <<7);
                data[3] <= gray_data;
            end
            4'd5:begin
                gray_addr <= (x1+1) + ((y1) <<7);
                data[4] <= gray_data;
            end
            4'd6:begin
                gray_addr <= (x1-1) + ((y1+1) <<7);
                data[5] <= gray_data;
                lbp_addr <= x1 + (y1 <<7);
                lbp_data[0] <= data[0] >= data[4] ? 1'b1:1'b0;
                lbp_data[1] <= data[1] >= data[4] ? 1'b1:1'b0;
            end
            4'd7:begin
                gray_addr <= (x1 ) + ((y1+1) <<7);
                data[6] <= gray_data;
                lbp_data[2] <= data[2] >= data[4] ? 1'b1:1'b0;
                lbp_data[3] <= data[3] >= data[4] ? 1'b1:1'b0;
            end
            4'd8:begin
                gray_addr <= (x1 + 1) + ((y1+1) <<7);
                data[7] <= gray_data;
                lbp_data[4] <= data[5] >= data[4] ? 1'b1:1'b0;
                lbp_data[5] <= data[6] >= data[4] ? 1'b1:1'b0;
            end
            4'd9:begin
                data[8] <= gray_data;
                state <= 3'd3;
                lbp_valid <= 1'd1;
                load <= 4'd0;
            end
            endcase
        end
        2'd2: begin//else
            load <= load + 4'd1;
            if(load == 4'd0)begin
                lbp_data[6] <= data[7] >= data[4] ? 1'b1:1'b0;
                lbp_data[7] <= data[8] >= data[4] ? 1'b1:1'b0;
                data[0] <= data[1];
                data[1] <= data[2];
                data[3] <= data[4];
                data[4] <= data[5];
                data[6] <= data[7];
                data[7] <= data[8];
                gray_addr <= (x1 + 1) + ((y1-1) <<7);
            end
            else if(load == 4'd1)begin
                gray_addr <= (x1 + 1) + ((y1) <<7);
                data[2] <= gray_data;
                lbp_addr <= x1 + (y1 <<7);
                lbp_data[0] <= data[0] >= data[4] ? 1'b1:1'b0;
                lbp_data[1] <= data[1] >= data[4] ? 1'b1:1'b0;
            end
            else if(load == 4'd2)begin
                gray_addr <= (x1 + 1) + ((y1 + 1) <<7);
                data[5] <= gray_data;
                lbp_data[2] <= data[2] >= data[4] ? 1'b1:1'b0;
                lbp_data[3] <= data[3] >= data[4] ? 1'b1:1'b0;
            end
            else if(load == 4'd3)begin
                data[8] <= gray_data;
                lbp_data[4] <= data[5] >= data[4] ? 1'b1:1'b0;
                lbp_data[5] <= data[6] >= data[4] ? 1'b1:1'b0;
                state <= 3'd3;
                lbp_valid <= 1'd1;
                load <= 4'd0;
            end
        end
        2'd3 : begin
            if (x == 8'd127 && y == 8'd126)begin
                finish <= 1'd1;
            end
            else if (y != 8'd126 && x == 8'd126) begin
                y <= y + 8'd1;
                x <= 8'd0;
            end
            else begin
                x <= x + 8'd1;
            end
            x1 <= x;
            y1 <= y;
            if(x == 8'd0)begin

            end
            else if(x == 8'd1)begin
                state <= 2'd1;
            end
            else begin
                state <= 2'd2; 
            end
        end
        endcase
    end
end
//====================================================================
endmodule
