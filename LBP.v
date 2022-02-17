`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output  reg [13:0] 	gray_addr;
output  reg       	gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output  reg [13:0] 	lbp_addr;
output  reg 	lbp_valid;
output  reg  [7:0] 	lbp_data;
output  reg 	finish;
reg   [9:0] ans[127:0][127:0];
reg   [9:0] arr[127:0][127:0];
reg  [8:0] x,y,ps_x,ps_y,w_x,w_y;
reg  [8:0] cm_x,cm_y;
reg [9:0] num,test,ddd;
reg        ok,end_count,det;
reg  [9:0]gg [2:0][2:0];
integer  i,j;
//====================================================================
always @(posedge clk or posedge reset) begin
    if(reset) begin
        gray_addr <= 14'd0;
        gray_req <= 1'd0;
        lbp_addr <= 14'd0;
        lbp_valid <= 1'd0;
        lbp_data <= 8'd0;
        finish <= 1'd0;
        x <= 9'd0;//read data//must be -1  why???
        y <= 9'd0;//read data
        ps_x <= 9'd1;//中心
        ps_y <= 9'd1;//中心
        cm_x <= 9'd0;//計算 //must be -1  why???
        cm_y <= 9'd0;//計算
        w_x <= 9'd0;//寫入 must be 0 why???
        w_y <= 9'd0;//寫入
        ok <= 1'd0;
        det <= 1'd0;//判斷進哪邊
        end_count <= 1'd0;
        num <= 10'd0;
        test <= 10'd0;
        ddd <= 10'd0;
        for(i=0;i<3;i=i+1)
            for(j=0;j<3;j=j+1)
                gg[i][j] <= 9'd0;
    end
    /*else if(gray_addr == 14'd16384) begin
        gray_req <= 1'd0;
        gray_addr <= 14'd0; // 別再進這個else if 
        det <= 1'd1;
    end*/


    else if(gray_ready && det == 1'd0) begin
        if(gray_req != 1'd1) begin
            gray_req <= 1'd1;
        end
        else begin
            gray_addr <= gray_addr +14'd1;
        
            if (x == 9'd128 && y == 9'd127) begin //check
                det <= 1'd1;
                gray_req <= 1'd0;
            end
            else if (x == 9'd127 && y != 9'd127) begin //check
                x <= 9'd0;
                y <= y + 9'd1;
            end
            else 
                x <= x + 9'd1; 
        arr[x][y] <= gray_data;
        test <= gray_data;            
        end
    end


    else if (gray_req == 0 && lbp_valid == 0)  begin //valid 的問題

        if ( (cm_x - ps_x == 9'd1) && (cm_y - ps_y == 9'd1)) begin //check
            //jump out
            //if (end_count == 1'd1) begin
              //  lbp_valid <= 1'd1;
            //end
            //else begin 
                ok <= 1'd1;
                ans[ps_x][ps_y] <= num;
                test <= num;
            //end
        end
        else if ((cm_x - ps_x == 9'd1) && (cm_y - ps_y != 9'd1)) begin
            cm_y <= cm_y + 9'd1;
            cm_x <= cm_x - 9'd2;
        end
        else begin
            cm_x <= cm_x + 9'd1;
        end

        //check
        
        // if (cm_x == ps_x && cm_y == ps_y) begin
        //     num <= num;
        // end
        // else if (arr[ps_x][ps_y] > arr[cm_x][cm_y]) begin
        //     num <= num;
        // end
        // else begin
        //     if((ps_x - cm_x)== 1 && (ps_y -cm_y)== 1) begin
        //         num <= num + 8'd1;
        //     end
        //     else if((ps_x - cm_x)== 0 && (ps_y -cm_y)== 1) begin
        //         num <= num + 8'd2;
        //     end
        //     else if((cm_x - ps_x)== 1 && (ps_y -cm_y)== 1) begin
        //         num <= num + 8'd4;
        //     end
        //     else if((ps_x - cm_x)== 1 && (ps_y - cm_y)== 0) begin
        //         num <= num + 8'd8;
        //     end
        //     else if((cm_x -ps_y)== 1 && (ps_y -cm_y)== 0) begin
        //         num <= num + 8'd16;
        //     end
        //     else if((ps_x - cm_x)== 1 && (cm_y -ps_y)== 1) begin
        //         num <= num + 8'd32;
        //     end
        //     else if((ps_x - cm_x)== 0 && (cm_y -ps_y)== 1) begin
        //         num <= num + 8'd64;
        //     end
        //     else if((cm_x - ps_x)== 1 && (cm_y -ps_y)== 1) begin
        //         num <= num + 8'd128;
        //     end
        //     //2
        // end
        
        if (ok == 1'd1) begin
            if(ps_x == 9'd126 && ps_y == 9'd126 ) begin //check125
                num <= 0;//?
                //end_count <= 1'd1;//finish
                lbp_valid <= 1;
                for(i=0;i<3;i=i+1)
            for(j=0;j<3;j=j+1)
                gg[i][j] <= 9'd0;
            end
            else if (ps_x == 9'd126 && ps_y != 9'd126) begin
                num <= 0;
                ps_y <= ps_y + 9'd1;
                ps_x <= 9'd1;
                cm_x <= 9'd0;
                cm_y <= ps_y + 9'd1 - 9'd1;
                ok <= 1'd0;
                for(i=0;i<3;i=i+1)
            for(j=0;j<3;j=j+1)
                gg[i][j] <= 9'd0;

            end
            else  begin
                num <= 0;
                for(i=0;i<3;i=i+1)
            for(j=0;j<3;j=j+1)
                gg[i][j] <= 9'd0;
                ps_x <= ps_x + 9'd1;
                cm_x <= ps_x + 9'd1 - 9'd1;
                cm_y <= ps_y - 9'd1;
                ok <= 1'd0;
            end
        end
    end


    else if (lbp_valid == 1'd1) begin
        lbp_addr <= lbp_addr + 14'd1;
        
        // if(w_x == 0 && w_y == 0) begin
        //     lbp_data <= 8'd3;
        // end
        //if (w_x == 9'd0 || w_y == 9'd0 || w_x == 9'd127 || w_y == 9'd127) begin
        if (w_x == 9'd0 && w_y == 9'd0) begin
            lbp_data <= 8'd0;
        end
        else 
        lbp_data <= ans[w_x][w_y]; //129沒給到值
        

        if (w_x == 9'd127 && w_y == 9'd127) begin //check
            finish <= 1'd1;
        end
        else if (w_x == 9'd127 && w_y != 9'd127) begin //check
            w_x <= 9'd0;
            w_y <= w_y + 9'd1;
        end
        else w_x <= w_x + 9'd1;
    end
end

always @(cm_x or cm_y or clk) begin
    ddd <= arr[cm_x][cm_y];
    if (cm_x == ps_x && cm_y == ps_y) begin
            
        end
        else if (arr[ps_x][ps_y] > arr[cm_x][cm_y]) begin
            
        end
        else begin
            if((ps_x - cm_x)== 1 && (ps_y -cm_y)== 1) begin
                num <= num + 8'd1;
            end
            else if((ps_x - cm_x)== 0 && (ps_y -cm_y)== 1) begin
                num <= num + 8'd2;
            end
            else if((cm_x - ps_x)== 1 && (ps_y -cm_y)== 1) begin
                num <= num + 8'd4;
            end
            else if((ps_x - cm_x)== 1 && (ps_y - cm_y)== 0) begin
                num <= num + 8'd8;
            end
            else if((cm_x -ps_x)== 1 && (ps_y -cm_y)== 0) begin
                num <= num + 8'd16;
            end
            else if((ps_x - cm_x)== 1 && (cm_y -ps_y)== 1) begin
                num <= num + 8'd32;
            end
            else if((ps_x - cm_x)== 0 && (cm_y -ps_y)== 1) begin
                num <= num + 8'd64;
            end
            else if((cm_x - ps_x)== 1 && (cm_y -ps_y)== 1) begin
                num <= num + 8'd128;
            end
            //2
        end
end

 





//====================================================================
endmodule