
`timescale 1ns/10ps
`include "ALU.v"

module alu_tb;
localparam CLK_PERIOD = 20;
reg clk;
// (clk , rst, enable, p, q, T,  helpmul, muldone, mul_a,neg_mul_a, mul_b,neg_mul_b, mul_result, helpmod, moddone, mod_a, neg_mod_a, mod_result, helpinvmod, invmoddone, invmod_a, neg_invmod_a, invmod_result, done, op); 
//reg rst;
// reg signed [63:0] i2;
// reg signed [63:0] i1;
reg  [128:0] i2;
reg  [128:0] i1;
reg  [1:0] op;
reg enable;
reg rst;


wire [128:0] outcome;
wire done;



ALU alu
(
	.clk(clk),
	.rst_n(rst),
	.alu_en(enable),
	.alu_P(i1),
	.alu_Q(i2),
	.alu_op(op),
	.alu_R(outcome),
	.alu_done(done)
);


always #(CLK_PERIOD/2) clk=~clk;

/*
initial 
begin
    $dumpfile("tb_test.fsdb");
    $dumpvars(0, tb_test);
end
*/

/*
initial 
begin
	$sdf_annotate("test_syn.sdf", t);
end
*/
/*
always @ (helpmul)begin//mul
	if(helpmul)begin
		# (5*CLK_PERIOD);
		mul_result = mul_a*mul_b;
		muldone = 1'b1;
		# (1*CLK_PERIOD);
		muldone = 1'b0;
	end
end

always @ (helpmod)begin//mod
	if(helpmod)begin
		# (5*CLK_PERIOD);
		mod_result = mod_a%109970;//10997031918897188677
		moddone = 1'b1;
		# (1*CLK_PERIOD);
		moddone = 1'b0;
	end
end

always @ (helpinvmod)begin//invmod
	if(helpinvmod)begin
		# (5*CLK_PERIOD);
		invmod_result = 87;
		invmoddone = 1'b1;
		# (1*CLK_PERIOD);
		invmoddone = 1'b0;
	end
end
*/
initial
begin
    $monitor($time, " %d * %d  outcome:  %d", i1, i2 ,outcome);    
end

initial begin
    clk=1'b1;rst = 1'b1;
	# (1*CLK_PERIOD);  rst = 1'b0;
	# (1*CLK_PERIOD);  rst = 1'b1;
    #(CLK_PERIOD) enable=1'b1; i1={1'd0,64'd93,64'd9};  i2={1'd0,64'd8626,64'd39}; op = 2'd0;
    #(CLK_PERIOD) enable=1'b0;             
    wait(done);                  
    #(CLK_PERIOD) enable=1'b1; i1={1'd0,64'd93,64'd9};  i2={1'd0,64'd26,64'd3}; op = 2'd2;
	//i1={1'd1,64'd93,64'd9};  i2={1'd1,64'd26,64'd3}; op = 2'd0;
    #(CLK_PERIOD) enable=1'b0;    
    wait(done);                  
    #(CLK_PERIOD) enable=1'b1; i1={1'd0,64'd93,64'd9};  i2={1'd1,64'd26,64'd3}; op = 2'd2;
	//i1={1'd1,64'd93,64'd9};  i2={1'd0,64'd26,64'd3}; op = 2'd1;
    #(CLK_PERIOD) enable=1'b0;   
    wait(done);                  
    #(CLK_PERIOD) enable=1'b1; i1={1'd1,64'd93,64'd9};  i2={1'd0,64'd26,64'd3}; op = 2'd2;
	//i1={1'd1,64'd93,64'd9};  i2={1'd1,64'd26,64'd3}; op = 2'd2;
    #(CLK_PERIOD) enable=1'b0;
    wait(done);
	#(CLK_PERIOD)
    $finish;
end

endmodule
