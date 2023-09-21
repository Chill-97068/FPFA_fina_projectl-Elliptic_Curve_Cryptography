//`include "MOD.v"
//`include "MUL64.v"
//`include "INV_MOD.v"
//`include "ADDDOUBLE.v"

module ALU(clk,rst,alu_en,alu_P,alu_Q,alu_op,alu_R,alu_done);
    input clk, rst;
    input alu_en;
    input [128:0] alu_P;
    input [128:0] alu_Q;
    output [128:0] alu_R;
    input [1:0] alu_op;
    output alu_done;

///////////////////////  
    // %
    wire mod_enable;
    wire [127:0] mod_a;
    wire mod_a_sign;
    wire mod_done;
    wire [63:0] mod_result;

//////////////////////////
    // *
    wire [63:0] mul64_mul1, mul64_mul2;
    wire mul64_mul1_sign, mul64_mul2_sign;
    wire mul64_enable;
    wire [127:0] mul64_result;
    wire mul64_done;


//////////////////////////
    //inv
    wire inv_enable;  
    wire [63:0] inv_t;
    wire inv_t_sign;
    wire inv_mod_enable;
    wire [127:0] inv_mod_input;
    wire inv_mod_input_sign;
    wire inv_mul64_enable;
    wire [63:0] inv_mul64_mul1, inv_mul64_mul2;
    wire inv_mul64_mul1_sign, inv_mul64_mul2_sign;
    wire inv_done;
    wire [63:0] inv_result;
    wire inv_mod_done;
    wire inv_mul64_done;

//////////////////////////
    //add_double
    //wire add_enable;
    //wire [128:0] add_p, add_q;
    //wire [128:0] add_t;
    wire add_mul64_enable;
    wire [63:0] add_mul64_mul1, add_mul64_mul2;
    wire add_mul64_mul1_sign, add_mul64_mul2_sign;
    wire add_mod_enable;
    wire [127:0] add_mod_input;
    wire add_mod_input_sign;
    wire add_inv_enable;
    //wire add_done;
    //wire [1:0] add_op;
    wire add_mul64_done;
    wire add_mod_done;

///////////////////////
/*
    wire inv_mod_en_OR_add_mod_en , inv_mul64_en_OR_add_mul64_en;
    assign inv_mod_en_OR_add_mod_en =  inv_mod_enable || add_mod_enable;
    assign inv_mul64_en_OR_add_mul64_en = inv_mul64_enable || add_mul64_enable;

    reg inv_use_mod_flag, inv_use_mul64_flag;

    always @(posedge clk or posedge inv_mod_en_OR_add_mod_en) begin
        if (inv_mod_en_OR_add_mod_en) begin
            inv_use_mod_flag <= (inv_mod_enable) ? 1'b1 : 1'b0;
        end
        else
        begin
            inv_use_mod_flag <= inv_use_mod_flag;
        end
    end

    always @(posedge clk or posedge inv_mul64_en_OR_add_mul64_en) begin
        if (inv_mul64_en_OR_add_mul64_en) begin
            inv_use_mul64_flag <= (inv_mul64_enable) ? 1'b1 : 1'b0;
        end
        else
        begin
            inv_use_mul64_flag <= inv_use_mul64_flag ;
        end
    end
    reg inv_mod_flag, inv_mul64_flag; //for inv
    always @(posedge clk) 
    begin
        if (inv_mod_enable) inv_mod_flag <= 1'b1;
        else if (add_mod_enable) inv_mod_flag <= 1'b0;

        if (inv_mul64_enable) inv_mul64_flag <= 1'b1;
        else if (add_mul64_enable) inv_mul64_flag <= 1'b0;
    end

*/
    parameter idle = 0;
    parameter segment1 = 1;
    parameter segment2 = 2;
    parameter segment3 = 3;
    parameter segment4 = 4;
    parameter segment5 = 5;
    parameter segment6 = 6;
    parameter segment7 = 7;
    parameter segment8 = 8;
    parameter segment9 = 9;   //3*rx
    parameter segment10 = 10; //(3*rx)*rx
    parameter segment11 = 11; //((3*rx)*rx)%p
    parameter segment12 = 12;
    parameter segment13 = 13;
    parameter segment14 = 14;
    parameter segment15 = 15;
    parameter segment16 = 16;
    parameter finish = 17;

    wire [4:0] add_state;



    //share input (% *)      (output use fanout)
    assign mod_enable = (add_state == segment2 || add_state == segment13) ? inv_mod_enable : add_mod_enable;
    assign mod_a = (add_state == segment2 || add_state == segment13) ? inv_mod_input :  add_mod_input;
    assign mod_a_sign = (add_state == segment2 || add_state == segment13) ? inv_mod_input_sign :  add_mod_input_sign;

    assign mul64_enable = (add_state == segment2 || add_state == segment13) ? inv_mul64_enable : add_mul64_enable ;
    assign mul64_mul1 = (add_state == segment2 || add_state == segment13) ?  inv_mul64_mul1 : add_mul64_mul1 ;
    assign mul64_mul2 =  (add_state == segment2 || add_state == segment13) ?  inv_mul64_mul2 : add_mul64_mul2 ;
    assign mul64_mul1_sign = (add_state == segment2 || add_state == segment13) ?  inv_mul64_mul1_sign : add_mul64_mul1_sign;
    assign mul64_mul2_sign = (add_state == segment2 || add_state == segment13) ?  inv_mul64_mul2_sign : add_mul64_mul2_sign;

    //share output 
    assign inv_mod_done = (add_state == segment2 || add_state == segment13) ? mod_done : 1'b0;
    assign inv_mul64_done = (add_state == segment2 || add_state == segment13) ? mul64_done : 1'b0;
    assign add_mod_done = (~(add_state == segment2 || add_state == segment13)) ? mod_done : 1'b0;
    assign add_mul64_done = (~(add_state == segment2 || add_state == segment13)) ? mul64_done : 1'b0;

////////////////////

////////////////////

    MOD mod
    (
        .clk(clk), 
        .enable(mod_enable), 
        .a(mod_a), 
        .a_sign(mod_a_sign), 
        .done(mod_done), 
        .result(mod_result)
    );

    MUL64 mul64
    (
        .clk(clk), 
        .mul1(mul64_mul1), 
        .mul2(mul64_mul2), 
        .mul1_sign(mul64_mul1_sign), 
        .mul2_sign(mul64_mul2_sign), 
        .enable(mul64_enable), 
        .result(mul64_result), 
        .done(mul64_done)
    );

    INV_MOD inv_mod
    (
        .clk(clk), 
        .rst_n(rst),
        .enable(add_inv_enable), 
        .t(inv_t), 
        .t_sign(inv_t_sign),
        .mod_done(inv_mod_done),
        .mod_result(mod_result), 
        .mul64_done(inv_mul64_done), 
        .mul64_result(mul64_result), 
        .mod_enable(inv_mod_enable), 
        .mod_input(inv_mod_input), 
        .mod_input_sign(inv_mod_input_sign),
        .mul64_enable(inv_mul64_enable), 
        .mul64_mul1(inv_mul64_mul1), 
        .mul64_mul2(inv_mul64_mul2), 
        .mul64_mul1_sign(inv_mul64_mul1_sign), 
        .mul64_mul2_sign(inv_mul64_mul2_sign),
        .done(inv_done), 
        .result(inv_result)
    );

    ADD_DOUBLE add_double
    (
        .clk(clk), 
        .rst_n(rst), 
        .enable(alu_en), 
        .p(alu_P), 
        .q(alu_Q), 
        .T(alu_R),  
        .helpmul(add_mul64_enable), 
        .muldone(add_mul64_done), 
        .mul_a(add_mul64_mul1), 
        .neg_mul_a(add_mul64_mul1_sign), 
        .mul_b(add_mul64_mul2), 
        .neg_mul_b(add_mul64_mul2_sign), 
        .mul_result(mul64_result), 
        .helpmod(add_mod_enable), 
        .moddone(add_mod_done), 
        .mod_a(add_mod_input), 
        .neg_mod_a(add_mod_input_sign), 
        .mod_result(mod_result), 
        .helpinvmod(add_inv_enable), 
        .invmoddone(inv_done), 
        .invmod_a(inv_t), 
        .neg_invmod_a(inv_t_sign),
        .invmod_result(inv_result), 
        .done(alu_done), 
        .op(alu_op),
        .state(add_state)
    ); 






endmodule