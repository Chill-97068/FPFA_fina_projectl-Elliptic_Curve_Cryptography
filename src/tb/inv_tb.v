
`timescale 1ns/10ps
`include "ALU_INV.v"

module inv_tb;
localparam CLK_PERIOD = 20;
reg clk;
//reg rst;
// reg signed [63:0] i2;
// reg signed [63:0] i1;
reg  [63:0] a;
reg rst_n;
reg enable; 
wire [63:0] outcome;
wire inv_done;

ALU_INV alu_inv
(   
    .clk(clk), 
    .rst_n(rst_n),
    .enable(enable), 
    .t(a),
    .result(outcome), 
    .inv_done(inv_done) 
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
integer i1;

always @(inv_done) begin
    if (inv_done) begin
        $display($time, " %d inv mod p  outcome:  %d       %h", a ,outcome ,outcome);    
    end
end

initial begin
        clk=1'b1;  rst_n=1'b1;
        /*
    #(CLK_PERIOD) rst_n=1'b0;
    #(CLK_PERIOD) rst_n=1'b1; enable=1'b1; a=64'd1;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd2;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd3;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd4;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd5;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd6;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd7;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd8;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd9;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd10;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd11;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd12;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd13;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd14;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd15;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd16;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd17;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
*/

    for ( i1=1 ; i1<50 ; i1=i1+1 ) begin
        #(CLK_PERIOD) enable=1'b1; a=i1;
        #(CLK_PERIOD) enable=1'b0;
        wait(inv_done);
        
        
    end

    /*
    #(CLK_PERIOD) enable=1'b1; a=64'd5213;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    #(CLK_PERIOD) enable=1'b1; a=64'd5213;
    #(CLK_PERIOD) enable=1'b0;
    wait(inv_done);
    */


    $finish;
end

endmodule