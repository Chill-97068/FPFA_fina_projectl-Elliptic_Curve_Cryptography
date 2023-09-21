`include "MOD.v"
`include "MUL64.v"
`include "INV_MOD.v"
//`include "ADDDOUBLE.v"

module ALU_INV(clk,enable, rst_n, t, inv_done, result);
    input clk , enable ;
    input rst_n;
    input [63:0] t;
    output [63:0] result;
    output inv_done;

///////////////////////  
    // %
    wire mod_enable;
    wire [127:0] mod_a;
    wire mod_a_sign;
    wire mod_valid;
    wire [63:0] mod_result;
    wire mod_done;
//////////////////////////
    // *
    wire [63:0] mul64_mul1, mul64_mul2;
    wire mul64_mul1_sign, mul64_mul2_sign;
    wire mul64_enable;
    wire [127:0] mul64_result;
    wire mul64_valid;
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
    wire inv_valid;
    wire [63:0] inv_result;
    /*
//////////////////////////
    //add_double
    wire add_enable;
    wire [128:0] add_p, add_q;
    wire [128:0] add_t;
    wire add_mul64_enable;
    wire mul64_valid;
    wire [63:0] add_mul64_mul1, add_mul64_mul2;
    wire add_mul64_mul1_sign, add_mul64_mul2_sign;
    wire [127:0] mul64_result;
    wire add_mod_enable;
    wire mod_valid;
    wire [63:0] add_mod_input;
    wire add_mod_input_sign;
    wire [63:0] mod_result;
    wire add_inv_enable;
    wire inv_valid;
    wire [63:0] inv_t;
    wire inv_t_sign;
    wire [63:0] inv_result;
    wire add_done;
    wire [1:0] add_op;
*/
///////////////////////
    //share input (% *)      (output use fanout)
    assign mod_enable =  inv_mod_enable ;
    assign mod_a =  inv_mod_input;
    assign mod_a_sign =  inv_mod_input_sign ;

    assign mul64_enable = inv_mul64_enable;
    assign mul64_mul1 =  inv_mul64_mul1 ;
    assign mul64_mul2 = inv_mul64_mul2 ;
    assign mul64_mul1_sign = inv_mul64_mul1_sign;
    assign mul64_mul2_sign =  inv_mul64_mul2_sign ;

////////////////////
    assign inv_enable = enable;
    assign inv_t = t;
    assign result = inv_result;


////////////////////

    MOD mod
    (
        .clk(clk), 
        .enable(mod_enable), 
        .a(mod_a), 
        .a_sign(mod_a_sign), 
        .result(mod_result),
        .done(mod_done)
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
        .rst_n(rst_n),
        .enable(inv_enable), 
        .t(inv_t), 
        .mod_result(mod_result),  
        .mul64_result(mul64_result), 
        .mul64_done(mul64_done),
        .mod_done(mod_done),
        .mod_enable(inv_mod_enable), 
        .mod_input(inv_mod_input), 
        .mod_input_sign(inv_mod_input_sign),
        .mul64_enable(inv_mul64_enable), 
        .mul64_mul1(inv_mul64_mul1), 
        .mul64_mul2(inv_mul64_mul2), 
        .mul64_mul1_sign(inv_mul64_mul1_sign), 
        .mul64_mul2_sign(inv_mul64_mul2_sign),
        .result(inv_result),
        .done(inv_done)
    );
/*
    ADD_DOUBLE add_double
    (
        .clk(clk), 
        .rst_n(rst_n), 
        .enable(add_enable), 
        .p(add_p), 
        .q(add_q), 
        .T(add_t),  
        .helpmul(add_mul_enable), 
        .muldone(mul64_valid), 
        .mul_a(add_mul64_mul1), 
        .neg_mul_a(add_mul64_mul1_sign), 
        .mul_b(add_mul64_mul2), 
        .neg_mul_b(add_mul64_mul2_sign), 
        .mul_result(mul64_result), 
        .helpmod(add_mod_enable), 
        .moddone(mod_valid), 
        .mod_a(add_mod_input), 
        .neg_mod_a(add_mod_input_sign), 
        .mod_result(mod_result), 
        .helpinvmod(add_inv_enable), 
        .invmoddone(inv_valid), 
        .invmod_a(inv_t), 
        .neg_invmod_a(inv_t_sign), 
        .invmod_result(inv_result), 
        .done(add_done), 
        .op(add_op)
    ); 
*/

endmodule