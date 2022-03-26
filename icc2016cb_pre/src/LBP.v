
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output reg [13:0] 	gray_addr;
output reg        	gray_req;
input   	gray_ready;
input   [7:0] 	gray_data;
output reg [13:0] 	lbp_addr;
output reg 	lbp_valid;
output reg [7:0] 	lbp_data;
output reg 	finish;
//====================================================================
reg [7:0] sub [8:0];
reg [3:0] i;
reg [2:0] state,next_state;
wire en[7:0];
wire [7:0] gc;


assign en[0]=(sub[0]>=sub[4])?1:0;
assign en[1]=(sub[1]>=sub[4])?1:0;
assign en[2]=(sub[2]>=sub[4])?1:0;
assign en[3]=(sub[3]>=sub[4])?1:0;
assign en[4]=(sub[5]>=sub[4])?1:0;
assign en[5]=(sub[6]>=sub[4])?1:0;
assign en[6]=(sub[7]>=sub[4])?1:0;
assign en[7]=(sub[8]>=sub[4])?1:0;
assign gc={en[7],en[6],en[5],en[4],en[3],en[2],en[1],en[0]};

always@(posedge clk or posedge reset)
begin
  //c<=c+1;
    if(reset)begin
        finish<=0;
        lbp_valid<=0;
        gray_addr<=0;
        i<=0;
        state<=0;
        gray_req<=1;
        lbp_addr<=129;
    end
    else begin
        case(state)
            0:  begin   //Read in nine elements
                    if(i==9)begin
                        state<=1;
                        i<=0;
                    end
                    else begin
                        i<=i+1;
                        
                        if(gray_addr==lbp_addr-127)
                            gray_addr<=lbp_addr-1;
                        else if (gray_addr==lbp_addr+1)
                            gray_addr<=lbp_addr+127;
                        else
                            gray_addr<=gray_addr+1;
                    end
                    
                          
                    sub[i]<=gray_data;
                end
            1:  begin
                    
                    lbp_valid<=1;
                    lbp_data<=gc;
                    state<=2;
                    
                end
            2:  begin
                    if(lbp_addr[6:0]==126)begin
                        if(lbp_addr==16254)begin    //Ending signal
                          finish<=1;
                          gray_req<=0;
                        end
                        else
                          lbp_addr<=lbp_addr+3;
                          gray_addr<=lbp_addr-126;
                          state<=0;
                    end
                    else begin
                        //best version
                        lbp_addr<=lbp_addr+1;
                        gray_addr<=lbp_addr-126;
                        state<=3;

                    end
                    
                end
            3:  begin
                    //best version
                    sub[1]<=sub[2];
                    sub[0]<=sub[1];
                    sub[6]<=sub[7];
                    sub[7]<=sub[8];
                    sub[3]<=sub[4];
                    sub[4]<=sub[5];

                    sub[2]<=gray_data;
                    gray_addr<=lbp_addr+1;
                    

                    state<=4;
                end
            4:  begin
                    sub[5]<=gray_data;
                    gray_addr<=lbp_addr+129;
                    state<=5;
                end
            5:  begin
                    sub[8]<=gray_data;
                    state<=1;
                end
            default: begin  end
        endcase
    end
end

//====================================================================
endmodule

