module INV_MOD
        (clk, rst_n, enable, t, t_sign, mod_done, mod_result, 
        mul64_done, mul64_result, mod_enable, mod_input, mod_input_sign, 
        mul64_enable, mul64_mul1, mul64_mul2, mul64_mul1_sign, mul64_mul2_sign, 
        done, result);
    input clk, rst_n;
    input enable;
    input [63:0] t;   //suppose 64 bits  ??????
    input t_sign;

    input mod_done, mul64_done;
    input [63:0] mod_result;
    input [127:0] mul64_result;
    output reg mod_enable, mul64_enable;
    output [127:0] mod_input;
    output mod_input_sign;
    output [63:0] mul64_mul1, mul64_mul2;
    output mul64_mul1_sign, mul64_mul2_sign;
    output done;
    output [63:0] result;

    
    wire [63:0] exp;
    //assign exp = 64'd15;
    assign exp = 64'd10997031918897188675;  // domain

    parameter MUL1  = 3'd0;
    parameter MOD1  = 3'd1;
    parameter MUL2  = 3'd2;
    parameter MOD2  = 3'd3;
    parameter DONE  = 3'd4;

    reg [6:0] iter, nx_iter;
    reg [2:0] st, nst;
    reg [63:0] x, t_exp;

    wire valid ;
    reg valid_reg;
    wire [63:0] t_abs;
    assign t_abs =  (t_sign) ? -t : t;

    assign valid = iter==7'd64;
    assign done = valid==1'd1 && valid != valid_reg;


    assign mod_input = mul64_result; 
    assign mod_input_sign =  1'b0;
    assign mul64_mul1 = (st== MUL1) ? x : (st==MUL2) ? t_exp : 64'd0;
    assign mul64_mul2 = (st== MUL1) ? t_exp : (st==MUL2) ? t_exp : 64'd0;
    assign mul64_mul1_sign =  1'b0;
    assign mul64_mul2_sign = 1'b0;    
    assign result = (t_sign) ? (exp+2) - x : x ;



    
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            iter <= 7'd0;
            st <= MUL1;
            x <= 64'd1;
            t_exp <= 64'd0;
            mul64_enable <= 1'b0;
            mod_enable <= 1'b0;
            valid_reg <= 1'b0;
        end
        else begin
            if (enable) begin
                iter <= 7'd0;
                st <= (~exp[0]) ? MUL2 : MUL1 ;
                x <= 64'd1;
                t_exp <= t_abs;
                mul64_enable <= 1'b1;
                mod_enable <= 1'b0;
            end
            else begin
                iter <= nx_iter;
                st <= nst;
                x <= (st==MOD1 && mod_done) ? mod_result : x;
                t_exp <= (st==MOD2 && mod_done) ? mod_result : t_exp;
                mul64_enable <= ((st==MOD1 || st==MOD2) && st!=nst) ? 1'b1 : 1'b0;
                mod_enable <= ((st==MUL1 || st==MUL2) && st!=nst) ? 1'b1 : 1'b0;      
            end    
            valid_reg <= valid;      
        end
    end

    wire log;
    assign log = ~exp[nx_iter[5:0]];

    always @(*) begin
        nx_iter = ( (st==MOD2 && mod_done )) ? iter + 7'd1 : iter;
        case (st)
            MUL1: nst = (mul64_done)  ? MOD1 : MUL1;
            MOD1: nst = (mod_done) ? MUL2 : MOD1;
            MUL2: nst = (mul64_done) ? MOD2 : MUL2;
            MOD2: nst = (mod_done) ? (iter==7'd63) ? DONE : (exp[nx_iter[5:0]]) ? MUL1 : MUL2 : MOD2;
            /*
            MOD2: begin
                if (mod_done) begin
                    if (iter==7'd63) begin
                        nst = DONE;
                    end
                    else
                    begin
                        if (exp[nx_iter[5:0]]) begin
                            nst = MUL1;
                        end
                        else
                        begin
                            nst = MUL2;
                        end
                    end
                end
                else begin
                    nst = MOD2 ;
                end
            end
            */

            default : nst = DONE;
        endcase
    end

endmodule


/*
function modular_pow(base, exponent, modulus)
    if modulus = 1 then return 0
    Assert :: (modulus - 1) * (modulus - 1) does not overflow base
    result := 1
    base := base mod modulus
    while exponent > 0
        if (exponent mod 2 == 1):
           result := (result * base) mod modulus
        exponent := exponent >> 1
        base := (base * base) mod modulus
    return result
*/