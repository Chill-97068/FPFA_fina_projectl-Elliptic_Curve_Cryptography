
module MOD (clk, enable, a, a_sign, done, result);  //128%64 =64     // negative mod output is ? YES
    input clk;
    input enable;
    input [127:0] a;        //is a signed/unsign input 
    input a_sign;
    output done;
    output [63:0] result;

    wire [63:0] p; 
    //assign p = 64'd17;  
    assign p = 64'd10997031918897188677;    //domain


    wire [64:0] q;     
    wire [127:0] a_abs;
    assign a_abs = a_sign ? -a : a;

    parameter times = 65;
    parameter dandsize = 128;
    parameter diorsize = 64;
    parameter qsize = 65;
    parameter stage_num = 1;

    reg [7:0] cnt;
    reg [64:0] q_reg; 

    wire valid;
    reg valid_reg;
    assign valid = cnt == times;
    assign done = valid ^ valid_reg;

    // size = dand size
    wire [(dandsize-1):0] dand0, dior0; // stage0 wire
    /*
    wire [(dandsize-1):0] dand1, dior1; // stage1 wire
    wire [(dandsize-1):0] dand2, dior2; // stage2 wire
    wire [(dandsize-1):0] dand3, dior3; // stage3 wire
    wire [(dandsize-1):0] dand4, dior4; // stage4 wire
    */
    reg  [(dandsize-1):0] dand5, dior5; // feedback register

    wire q_stage_0 ;//, q_stage_1, q_stage_2,q_stage_3,q_stage_4;

    // stage0
    assign dand0 = enable ? a_abs : dand5;
    assign dior0 = enable ? { p, {(dandsize-diorsize){1'b0}} } : dior5 ;
    assign q_stage_0 = dand0 >= dior0;
    /*
    // stage1
    assign dand1 = dand0 >= dior0 ? dand0-dior0 : dand0;
    assign dior1 = { 1'b0, dior0[(dandsize-1):1] };
    assign q_stage_1 = dand1 >= dior1;
    // stage2
    assign dand2 = dand1 >= dior1 ? dand1-dior1 : dand1;
    assign dior2 = { 1'b0, dior1[(dandsize-1):1] };
    assign q_stage_2 = dand2 >= dior2;
    // stage3
    assign dand3 = dand2>= dior2 ? dand2-dior2 : dand2;
    assign dior3 = { 1'b0, dior2[(dandsize-1):1] };
    assign q_stage_3 = dand3 >= dior3;
    // stage4
    assign dand4 = dand3 >= dior3 ? dand3-dior3 : dand3;
    assign dior4 = { 1'b0, dior3[(dandsize-1):1] };
    assign q_stage_4 = dand4 >= dior4;
    */
    // stage5
    always @ (posedge clk or posedge enable) begin
    	if(enable) begin
    		dand5 <= dand0 >= dior0 ? dand0-dior0 : dand0;
    		dior5 <= { 1'b0, dior0[(dandsize-1):1] };
    		cnt <= 8'd1;		
    		q_reg <= { {(qsize-stage_num){1'b0}}, q_stage_0} ;
            valid_reg <= 1'b0;
    	end
    	else begin
            if(cnt < times) begin
                cnt <=  cnt + 8'd1;
                dand5 <= (dand0 >= dior0) ? (dand0-dior0) : dand0;
                dior5 <= { 1'b0, dior0[(dandsize-1):1] };
                q_reg <= { q_reg[(qsize-stage_num-1):0], q_stage_0 } ;
    	    end
            valid_reg <= valid;
        end
    	// else keep
    end

    assign q = (a_sign ) ? -q_reg : q_reg;
    assign result =  (a_sign) ? (p-dand5[63:0]) : dand5;

endmodule


