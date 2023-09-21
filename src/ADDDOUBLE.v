//`include "MUL64.v"
//`include "MOD.v"
//`include "INV_MOD.v"
//`include "controller.v"

module ADD_DOUBLE (clk , rst_n, enable, p, q, T,  
helpmul, muldone, mul_a,neg_mul_a, mul_b,neg_mul_b, mul_result, helpmod, 
moddone, mod_a, neg_mod_a, mod_result, helpinvmod, 
invmoddone, invmod_a, neg_invmod_a, invmod_result, done, op ,state); 
input clk , rst_n, enable;
input [128:0] p, q;
input muldone, moddone, invmoddone;
input [63:0]  mod_result, invmod_result;
input [127:0] mul_result;
input [1:0] op;
output T;
output reg done;
output reg helpmul, helpmod, helpinvmod;
output reg [63:0] mul_a, mul_b, invmod_a;
output reg [127:0] mod_a;
output reg neg_mod_a , neg_mul_a, neg_mul_b ,neg_invmod_a; 
output reg [4:0] state;
reg  [4:0] prstate , nstate;
reg  [1:0] op_reg;

reg  [128:0] s1 , s2 , s;
reg  [63:0] px , py ;
reg  [63:0] qx , qy ;
reg  [63:0] tx , ty ;
reg  [128:0]T;//OUTPUT
wire [63:0] s1_tmp_x;
wire [63:0] s2_tmp_y;
wire [63:0] qy_c;
wire [63:0] tx_sub,ty_sub;
//wire [63:0] a = 128'd2;
wire [63:0] a = 64'd3628449283386729367;// domain

wire [63:0] coeffi_double_2 = 64'd2;
wire [63:0] coeffi_double_3 = 64'd3;

parameter idle = 5'd0;
parameter segment1 = 5'd1;
parameter segment2 = 5'd2;
parameter segment3 = 5'd3;
parameter segment4 = 5'd4;
parameter segment5 = 5'd5;
parameter segment6 = 5'd6;
parameter segment7 = 5'd7;
parameter segment8 = 5'd8;
parameter segment9 = 5'd9;   //3*rx
parameter segment10 = 5'd10; //(3*rx)*rx
parameter segment11 = 5'd11; //((3*rx)*rx)%p
parameter segment12 = 5'd12;
parameter segment13 = 5'd13;
parameter segment14 = 5'd14;
parameter segment15 = 5'd15;
parameter segment16 = 5'd16;
parameter finish = 5'd17;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
		state <= idle;
	else
		state <= nstate;
end

always @(posedge clk) begin
    if (~rst_n)
		prstate <= state;
	else
		prstate <= state;
end

always @(*) begin
    case(state)
		idle:begin
			/*
			if ((enable)&&(~(op == 2'd2))&&(~(p[128])&&~(q[128])))
				nstate = segment1;
			else if (enable&&(op == 2'd2)&&(~(p[128])))
				nstate = segment9;
			else if (enable&&(op != 2'd2)&&(p[128]&&(~q[128])))//infinite p + finite q
				nstate = segment14;
			else if (enable&&(op != 2'd2)&&((~p[128])&&q[128]))//infinite q + finite p
				nstate = segment15;
			else if (enable&&(((op == 2'd2)&&(p[128]))||((op != 2'd2)&&(p[128])&&(q[128]))))//infinite
				nstate = segment16;
			else
				nstate = idle;
			*/


			if (enable) begin
				if ((op == 2'd2) && (~(p[128])))
					nstate = segment9;
				else if (((op == 2'd0 || op == 2'd1)) && (~(p[128])&&~(q[128])))
					nstate = segment1;				
				else if (((op == 2'd0 || op == 2'd1)) && (p[128]&&(~q[128])) )//infinite p + finite q
					nstate = segment14;
				else if (((op == 2'd0 || op == 2'd1)) && ((~p[128])&&q[128]) )//infinite q + finite p
					nstate = segment15;
				else if ((((op == 2'd2)&&(p[128])) || ((op == 2'd0 || op == 2'd1) && (p[128])&&(q[128]))))//infinite
					nstate = segment16;
			end
			else begin
				nstate = idle;
			end
		end
		segment1:begin
			if(moddone)
				nstate =  segment2;
			else
				nstate =  segment1;
		end
		segment2:begin
			if(invmoddone)
				nstate =  segment3;
			else
				nstate =  segment2;
		end
		segment3:begin
			if(muldone)
				nstate =  segment4;
			else
				nstate =  segment3;
		end
		segment4:begin
			if(moddone)
				nstate =  segment5;
			else
				nstate =  segment4;
		end
		segment5:begin
			if(muldone)
				nstate =  segment6;
			else
				nstate =  segment5;
		end
		segment6:begin
			if(moddone)
				nstate =  segment7;
			else
				nstate =  segment6;
		end
		segment7:begin
			if(muldone)
				nstate =  segment8;
			else
				nstate =  segment7;
		end
		segment8:begin
			if(moddone)
				nstate =  finish;
			else
				nstate =  segment8;
		end
		segment9:begin
			if(muldone)
				nstate =  segment10;
			else
				nstate =  segment9;
		end
		segment10:begin
			if(muldone)
				nstate =  segment11;
			else
				nstate =  segment10;
		end
		segment11:begin
			if(moddone)
				nstate =  segment12;
			else
				nstate =  segment11;
		end
		segment12:begin
			if(muldone)
				nstate =  segment13;
			else
				nstate =  segment12;
		end
		segment13:begin
			if(invmoddone)
				nstate =  segment3;
			else
				nstate =  segment13;
		end
		segment14:begin
				nstate =  finish;
		end
		segment15:begin
				nstate =  finish;
		end
		segment16:begin
				nstate =  finish;
		end
		default ://finish
			nstate = idle;
	endcase
end

always @(posedge clk or negedge rst_n) begin//px py//qx qy
	if(~rst_n)begin
		px <= 64'd0;
		py <= 64'd0;
		qx <= 64'd0;
		qy <= 64'd0;
		op_reg <= 2'd0;
	end
	else if (enable &&((nstate != segment14)||(nstate != segment15)||(nstate != segment16)||(nstate != idle)))begin
		py <= p[127:64];
		px <= p[63:0];
		qy <= q[127:64];
		qx <= q[63:0];
		op_reg <= op;
	end
	else if (enable&&(nstate == segment14)&&(op == 2'd1))begin//finite q
		py <= 64'd0;
		px <= 64'd0;
		qy <= qy - q[127:64];
		qx <= q[63:0];
		op_reg <= op;
	end
	else if (enable&&(nstate == segment14)&&(op == 2'd0))begin//finite q
		py <= 64'd0;
		px <= 64'd0;
		qy <= qy + q[127:64];
		qx <= q[63:0];
		op_reg <= op;
	end
	else if (enable&&(nstate == segment15)&&(op == 2'd1))begin//finite p
		py <= py - p[127:64];
		px <= p[63:0];
		qy <= 64'd0;
		qx <= 64'd0;
		op_reg <= op;
	end
	else if (enable&&(nstate == segment15)&&(op == 2'd0))begin//finite p
		py <= py + p[127:64];
		px <= p[63:0];
		qy <= 64'd0;
		qx <= 64'd0;
		op_reg <= op;
	end
	else if (enable&&(nstate == segment16))begin
		py <= 64'd0;
		px <= 64'd0;
		qy <= 64'd0;
		qx <= 64'd0;
		op_reg <= op;
	end
	else if (enable&&(nstate == idle))begin
		py <= 64'd0;
		px <= 64'd0;
		qy <= 64'd0;
		qx <= 64'd0;
		op_reg <= op;
	end
	else begin
		py <= py;
		px <= px;
		qy <= qy;
		qx <= qx;
		op_reg <= op_reg;
	end
end

assign qy_c =(op==2'd1)? -qy : qy;
assign s2_tmp_y = py - qy_c;
assign s1_tmp_x = px - qx;

always @(posedge clk or negedge rst_n) begin//s1//add 00 / sub 01 / double 10
	if(~rst_n)
		s1 <= 128'd0;
	else if((state == segment1)&&(moddone))
		s1 <= mod_result;
	else if((state == segment9)&&(muldone))
		s1 <= mul_result ;
	else if((state == segment10)&&(muldone))
		s1 <= mul_result + a;
	else if((state == segment11)&&(moddone))
		s1 <= mod_result;
	else if(nstate == idle)
		s1 <= 128'd0;
	else
		s1 <= s1;
end

always @(posedge clk or negedge rst_n) begin//s2 //add 00 / sub 01 / double 10
	if(~rst_n)
		s2 <= 128'd0;
	else if((state == segment2)&&(~(op_reg == 2'd2))&&(invmoddone))
		s2 <= invmod_result;
	else if((state == segment12)&&((op_reg == 2'd2))&&(muldone)) //2*rx
		s2 <= mul_result;
	else if((state == segment13)&&((op_reg == 2'd2))&&(invmoddone)) //inv 2*rx
		s2 <= invmod_result;
	else if(state == idle)
		s2 <= 128'd0;
	else
		s2 <= s2;
end

always @(posedge clk or negedge rst_n) begin//s //add 00 / sub 01 / double 10
	if(~rst_n)
		s <= 128'd0;
	else if((state == segment3)&&(muldone))//s1*s2
		s <= mul_result;
	else if((state == segment4)&&(moddone)) // %p
		s <= mod_result;
	else if(state == idle)
		s <= 128'd0;
	else
		s <= s;
end

assign tx_sub =(op_reg == 2'd2)? (tx - px - px) : (tx - px - qx);

always @(posedge clk or negedge rst_n) begin//tx//add 00 / sub 01 / double 10
	if(~rst_n)
		tx <= 128'd0;
	else if((state == segment5)&&(muldone))//s*s
		tx <= mul_result;
	else if((state == segment6)&&(moddone))//%p
		tx <= mod_result;
	else if(state == segment14)
		tx <= tx+q[63:0];
	else if(state == segment15)
		tx <= tx+p[63:0];
	else if(state == segment16)
		tx <= 64'd0;
	else if(state == idle)
		tx <= 64'd0;
	else
		tx <= tx;
end

assign ty_sub = px - tx;

always @(posedge clk or negedge rst_n) begin//ty//add 00 / sub 01 / double 10
	if(~rst_n)
		ty <= 129'd0;
	else if((state == segment7)&&(muldone))//s*(px-tx)-py
		ty <= mul_result - py;
	else if((state == segment8)&&(moddone))//%p
		ty <= mod_result;
	else if((state == segment14)&&(op==2'd1))
		ty <= ty - q[127:64];
	else if((state == segment14)&&(op==2'd0))
		ty <= ty + q[127:64];
	else if((state == segment15)&&(op==2'd1))
		ty <= ty - p[127:64];
	else if((state == segment15)&&(op==2'd0))
		ty <= ty + p[127:64];
	else if(state == segment16)
		ty <= 64'd0;
	else if(state == idle)
		ty <= 64'd0;
	else
		ty <= ty;
end

always @(*) begin//mul_a, mul_b//neg_mul_a, neg_mul_b; 
	case(state)
		segment3:begin
			mul_a = s1;
			mul_b = s2;
			neg_mul_a = 1'd0; 
			neg_mul_b = 1'd0;
		end
		segment5:begin
			mul_a = s;
			mul_b = s;
			neg_mul_a =  1'd0 ; 
			neg_mul_b =  1'd0 ;
		end
		segment7:begin
			mul_a = s;
			mul_b = ty_sub;
			neg_mul_a = 1'd0 ; 
			neg_mul_b = ty_sub[63];
		end
		segment8:begin
			mul_a = s;
			mul_b = ty_sub;
			neg_mul_a = 1'd0 ; 
			neg_mul_b = ty_sub[63];
		end
		segment9:begin
			mul_a = coeffi_double_3;
			mul_b = px;
			neg_mul_a = 1'd0 ; 
			neg_mul_b = 1'd0 ;
		end
		segment10:begin
			mul_a = s1;
			mul_b = px;
			neg_mul_a = 1'd0 ; 
			neg_mul_b = 1'd0 ;
		end
		segment12:begin
			mul_a = coeffi_double_2;
			mul_b = py;
			neg_mul_a = 1'd0 ; 
			neg_mul_b = 1'd0 ;
		end
		default:begin
			mul_a = 64'd0;
			mul_b = 64'd0;
			neg_mul_a = 1'd0; 
			neg_mul_b = 1'd0;
		end
	endcase
end

always @(*) begin//mod_a //neg_mod_a
	case(state)
		segment1:begin
			mod_a = {{64{s2_tmp_y[63]}},s2_tmp_y};
			neg_mod_a = s2_tmp_y[63];
		end
		segment4:begin
			mod_a = s;
			neg_mod_a = s[127] ;
		end
		segment6:begin
			mod_a = {{64{tx_sub[63]}},tx_sub};
			neg_mod_a = tx_sub[63] ;
		end
		segment8:begin
			mod_a = {{64{ty[63]}},ty};
			neg_mod_a = ty[63];
		end
		segment11:begin
			mod_a = s1;
			neg_mod_a = s1[127]; 
		end
		default:begin
			mod_a = 128'd0;
			neg_mod_a = 1'd0;
		end
	endcase
end

always @(*) begin//invmod_a//neg_invmod_a
	case(state)
		segment2:begin
			neg_invmod_a =  s1_tmp_x[63];
			invmod_a =  s1_tmp_x;
		end
		segment13:begin
			invmod_a = s2;
			neg_invmod_a =  1'd0;
		end
		default:begin
			invmod_a = 64'd0;
			neg_invmod_a =  1'd0;
		end
	endcase
end

always @(*) begin//T
	T = (((op_reg == 2'd2)&&(p[128]))||((op_reg != 2'd2)&&(p[128])&&(q[128])))? {1'b1 , ty , tx } : {1'b0 , ty , tx };
end

always @(*) begin//mul//add 00 / sub 01 / double 10
	if(~rst_n)
		helpmul = 1'd0;
	else if((nstate == segment3)&&(prstate!=state))
		helpmul = 1'd1;
	else if((nstate == segment5)&&(prstate!=state))
		helpmul = 1'd1;
	else if((nstate == segment7)&&(prstate!=state))
		helpmul = 1'd1;
	else if((nstate == segment9)&&(prstate!=state))
		helpmul = 1'd1;
	else if((nstate == segment10)&&(prstate!=state))
		helpmul = 1'd1;
	else if((nstate == segment12)&&(prstate!=state))
		helpmul = 1'd1;
	else 
		helpmul = 1'd0;
end

always @(*) begin//mod//add 00 / sub 01 / double 10
	if(~rst_n)
		helpmod = 1'd0;
	else if((nstate == segment1)&&(prstate!=state))
		helpmod = 1'd1;
	else if((nstate == segment4)&&(prstate!=state))
		helpmod = 1'd1;
	else if((nstate == segment6)&&(prstate!=state))
		helpmod = 1'd1;
	else if((nstate == segment8)&&(prstate!=state))
		helpmod = 1'd1;
	else if((nstate == segment11)&&(prstate!=state))
		helpmod = 1'd1;
	else 
		helpmod = 1'd0;
end

always @(*) begin//invmod//add 00 / sub 01 / double 10
	if(~rst_n)
		helpinvmod = 1'd0;
	else if((nstate == segment2)&&(prstate!=state))
		helpinvmod = 1'd1;
	else if((nstate == segment13)&&(prstate!=state))
		helpinvmod = 1'd1;
	else 
		helpinvmod = 1'd0;
end

always @(*) begin//invmod//add 00 / sub 01 / double 10
	case(state)
		finish:
			done = 1'd1;
		default:
			done = 1'd0;
	endcase
end

endmodule