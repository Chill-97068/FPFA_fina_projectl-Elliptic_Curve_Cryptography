module MUL64 (clk, mul1, mul2, mul1_sign, mul2_sign ,enable, result, done);      //unsigned (if signed input ==> need preconvert to unsigned)
    input clk;
    input [63:0] mul1, mul2;
    input mul1_sign, mul2_sign;
    input enable;        //enable only 1 cycle
    output [127:0] result;
    output done;

    parameter MUL = 2'b0;
    parameter ADD = 2'd1;
    parameter DONE = 2'd2;

    reg [1:0] st,nst;
    reg [1:0] cnt;
    wire [3:0] base_addr;
    assign base_addr = cnt << 2'd2;

    reg [127:0] result_reg;
    reg [31:0] temp_result [0:15];
    reg [127:0] nx_result;

    wire [63:0] mul1_abs, mul2_abs;
    assign mul1_abs = (mul1_sign) ? -mul1 : mul1;
    assign mul2_abs = (mul2_sign) ? -mul2 : mul2;

    reg [15:0] temp1_mul1, temp1_mul2;
    wire [31:0] temp1_mul_result;
    assign temp1_mul_result = temp1_mul1* temp1_mul2; 

    reg [15:0] temp2_mul1, temp2_mul2;
    wire [31:0] temp2_mul_result;
    assign temp2_mul_result = temp2_mul1* temp2_mul2; 

    reg [15:0] temp3_mul1, temp3_mul2;
    wire [31:0] temp3_mul_result;
    assign temp3_mul_result = temp3_mul1* temp3_mul2; 

    reg [15:0] temp4_mul1, temp4_mul2;
    wire [31:0] temp4_mul_result;
    assign temp4_mul_result = temp4_mul1* temp4_mul2; 

    wire valid;
    reg valid_reg;
    assign result = (mul1_sign ^ mul2_sign) ? -result_reg : result_reg; 
    assign valid = st==DONE;
    assign done = valid ^ valid_reg;

    integer i1;

    always @(posedge clk or posedge enable) 
    begin
        if (enable)     //synch     //enable only 1 cycle
        begin
            st <= MUL ; 
            cnt <= 2'd0;
            for ( i1=0 ; i1<16; i1=i1+1) begin
                temp_result[cnt] <= 32'd0;
            end
            result_reg <= 128'd0;
            valid_reg <= 1'b0;
        end
        else
        begin
            st <= nst;
            cnt <= (st!=nst) ? 2'd0 : cnt + 2'd1;
            if (st==MUL)
            begin
                temp_result[base_addr]      <= temp1_mul_result; 
                temp_result[base_addr+4'd1] <= temp2_mul_result;    
                temp_result[base_addr+4'd2] <= temp3_mul_result; 
                temp_result[base_addr+4'd3] <= temp4_mul_result; 
            end 
            if (st==ADD)
            begin
                result_reg <= result_reg + nx_result;    
            end   
            valid_reg <= valid;
        end
    end


    always @(*) 
    begin
        case (st)
            MUL: nst = (cnt==2'd3) ? ADD : MUL;
            ADD: nst = (cnt==2'd3) ? DONE : ADD;
            DONE: nst = DONE;
            default: nst = MUL; 
        endcase    
    end

    always @(*) 
    begin
        nx_result = 128'd0;
        case (cnt)
            2'd0:begin
                temp1_mul1 = mul1_abs[15:0];
                temp1_mul2 = mul2_abs[15:0];
                temp2_mul1 = mul1_abs[15:0];
                temp2_mul2 = mul2_abs[31:16];
                temp3_mul1 = mul1_abs[15:0];
                temp3_mul2 = mul2_abs[47:32];
                temp4_mul1 = mul1_abs[15:0];
                temp4_mul2 = mul2_abs[63:48];

                nx_result = ({96'd0,temp_result[0]} << 0) + ({96'd0,temp_result[1]} << 16) + ({96'd0,temp_result[2]} << 32) + ({96'd0,temp_result[3]} << 48) ;
            end 
            2'd1:begin
                temp1_mul1 = mul1_abs[31:16];
                temp1_mul2 = mul2_abs[15:0];
                temp2_mul1 = mul1_abs[31:16];
                temp2_mul2 = mul2_abs[31:16];
                temp3_mul1 = mul1_abs[31:16];
                temp3_mul2 = mul2_abs[47:32];
                temp4_mul1 = mul1_abs[31:16];
                temp4_mul2 = mul2_abs[63:48];

                nx_result = ({96'd0,temp_result[4]} << 16) + ({96'd0,temp_result[5]} << 32) + ({96'd0,temp_result[6]} << 48) + ({96'd0,temp_result[7]} << 64) ;
            end 
            2'd2:begin
                temp1_mul1 = mul1_abs[47:32];
                temp1_mul2 = mul2_abs[15:0];
                temp2_mul1 = mul1_abs[47:32];
                temp2_mul2 = mul2_abs[31:16];
                temp3_mul1 = mul1_abs[47:32];
                temp3_mul2 = mul2_abs[47:32];
                temp4_mul1 = mul1_abs[47:32];
                temp4_mul2 = mul2_abs[63:48];
               

                nx_result = ({96'd0,temp_result[8]} << 32) + ({96'd0,temp_result[9]} << 48) + ({96'd0,temp_result[10]} << 64) + ({96'd0,temp_result[11]} << 80) ;
            end 
            2'd3:begin
                temp1_mul1 = mul1_abs[63:48];
                temp1_mul2 = mul2_abs[15:0];
                temp2_mul1 = mul1_abs[63:48];
                temp2_mul2 = mul2_abs[31:16];
                temp3_mul1 = mul1_abs[63:48];
                temp3_mul2 = mul2_abs[47:32];
                temp4_mul1 = mul1_abs[63:48];
                temp4_mul2 = mul2_abs[63:48];

                nx_result = ({96'd0,temp_result[12]} << 48) + ({96'd0,temp_result[13]} << 64) + ({96'd0,temp_result[14]} << 80) + ({96'd0,temp_result[15]} << 96) ;
            end 
        endcase
    end 

    


    
endmodule