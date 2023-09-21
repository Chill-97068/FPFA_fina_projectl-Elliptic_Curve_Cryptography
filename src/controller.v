module controller (
    input clk,
    input rst,
    input [31:0] inst,
    input [31:0] mem_rd,
    output reg [31:0] mem_wd,
    output reg [12:0] mem_a,
    output reg mem_wen,
    output [3:0] st,

    output reg [128:0] alu_P,
    output reg [128:0] alu_Q,
    input [128:0] alu_R,
    output reg [1:0] alu_op,
    output reg alu_en,
    input alu_done
);
    
parameter IDLE = 4'd0;
parameter WAIT_INST = 4'd1;
parameter GEN_KEY_INIT = 4'd2;
parameter CAL_K_kG = 4'd3;
parameter STORE_K = 4'd4;
parameter ENCRYPT_INIT = 4'd5;
parameter CAL_C1_rG = 4'd6;
parameter CAL_C2_rK = 4'd7;
parameter CAL_C2_M_add_rK = 4'd8;
parameter STORE_C1C2 = 4'd9;
parameter DECRYPT_INIT = 4'd10;
parameter CAL_M_kC1 = 4'd11;
parameter CAL_M_C2_sub_kC1 = 4'd12;
parameter STORE_M = 4'd13;
parameter DONE = 4'd14;

parameter ADD_ALU_OP = 2'b00;
parameter SUB_ALU_OP = 2'b01;
parameter DOUBLE_ALU_OP = 2'b10;

parameter k_mem_addr = 0;
parameter Kx_mem_addr = 8;
parameter Ky_mem_addr = 16;
parameter Mx_mem_addr = 24;
parameter My_mem_addr = 32;
parameter Gx_mem_addr = 40;
parameter Gy_mem_addr = 48;
parameter C1x_mem_addr = 56;
parameter C1y_mem_addr = 64;
parameter C2x_mem_addr = 72;
parameter C2y_mem_addr = 80;
parameter r_mem_addr = 88;
parameter done_mem_addr = 96;

wire [63:0] sc_mul_a;
reg [128:0] sc_mul_P;
wire [128:0] sc_mul_R;
reg sc_mul_en;
wire sc_mul_done;
wire [128:0] sc_mul_alu_P;
wire [128:0] sc_mul_alu_Q;
wire [128:0] sc_mul_alu_R;
wire [1:0] sc_mul_alu_op;
wire sc_mul_alu_en;
wire sc_mul_alu_done;

scalar_multipler sc (
    .clk(clk),
    .rst(rst),
    .a(sc_mul_a),
    .P(sc_mul_P),
    .R(sc_mul_R),
    .sc_mul_en(sc_mul_en),
    .sc_mul_done(sc_mul_done),
    .alu_P(sc_mul_alu_P),
    .alu_Q(sc_mul_alu_Q),
    .alu_R(sc_mul_alu_R),
    .alu_op(sc_mul_alu_op),
    .alu_en(sc_mul_alu_en),
    .alu_done(sc_mul_alu_done)
); 
reg [3:0] st, nst, prev_st;
reg [5:0] cnt;
reg [63:0] k_r_reg;
reg [128:0] K_reg;
reg [128:0] G_reg;
reg [128:0] C1_reg;
reg [128:0] C2_reg;
reg [128:0] M_reg;

// state machine
always @(posedge clk or negedge rst) begin
    if(~rst) begin
        st <= IDLE; 
        prev_st <= IDLE; 
        cnt <= 0;
    end
    else begin
        st <= nst;
        prev_st <= st;
        cnt <= st != nst ? 0 : cnt + 1;
    end
end
always @(*) begin
    case (st)
    IDLE: nst = inst == 0 ? WAIT_INST : IDLE;
    WAIT_INST: 
        nst =   inst == 1 ? GEN_KEY_INIT : 
                inst == 2 ? ENCRYPT_INIT : 
                inst == 3 ? DECRYPT_INIT : WAIT_INST;
    GEN_KEY_INIT: nst = cnt == 11 ? CAL_K_kG : GEN_KEY_INIT;
    CAL_K_kG: nst = sc_mul_done ? STORE_K : CAL_K_kG;
    STORE_K: nst = cnt == 3 ? DONE : STORE_K;
    ENCRYPT_INIT: nst = cnt == 27 ? CAL_C1_rG : ENCRYPT_INIT;
    CAL_C1_rG: nst = sc_mul_done ? CAL_C2_rK : CAL_C1_rG;
    CAL_C2_rK: nst = sc_mul_done ? CAL_C2_M_add_rK : CAL_C2_rK;
    CAL_C2_M_add_rK: nst = alu_done ? STORE_C1C2 : CAL_C2_M_add_rK;
    STORE_C1C2: nst = cnt == 7 ? DONE : STORE_C1C2;
    DECRYPT_INIT : nst = cnt == 19 ? CAL_M_kC1 : DECRYPT_INIT;
    CAL_M_kC1 : nst = sc_mul_done ? CAL_M_C2_sub_kC1 : CAL_M_kC1;
    CAL_M_C2_sub_kC1 : nst = alu_done ? STORE_M : CAL_M_C2_sub_kC1;
    STORE_M : nst = cnt == 3 ? DONE : STORE_M;
    DONE : nst = IDLE;
    default: nst = IDLE;
    endcase
end

// registers (k_r_reg, K_reg, G_reg, C1_reg, C2_reg, M_reg)
always @(posedge clk) begin
    case (st)
    GEN_KEY_INIT: begin
        if(cnt == 1) k_r_reg[31:00] <= mem_rd; // k
        else if(cnt == 3) k_r_reg[63:32] <= mem_rd; // k
        else if(cnt == 5) G_reg[31:00] <= mem_rd; // Gx
        else if(cnt == 7) G_reg[63:32] <= mem_rd; // Gx
        else if(cnt == 9) G_reg[95:64] <= mem_rd; // Gy
        else if(cnt == 11) G_reg[128:96] <= { 1'b0, mem_rd }; // Gy
    end
    CAL_K_kG:  begin
        if(sc_mul_done) K_reg <= sc_mul_R;
    end
    ENCRYPT_INIT: begin
        if(cnt == 1) k_r_reg[31:00] <= mem_rd; // r
        else if(cnt == 3) k_r_reg[63:32] <= mem_rd; // r
        else if(cnt == 5) G_reg[31:00] <= mem_rd; // Gx
        else if(cnt == 7) G_reg[63:32] <= mem_rd; // Gx
        else if(cnt == 9) G_reg[95:64] <= mem_rd; // Gy
        else if(cnt == 11) G_reg[128:96] <= { 1'b0, mem_rd }; // Gy
        else if(cnt == 13) K_reg[31:00] <= mem_rd; // Kx
        else if(cnt == 15) K_reg[63:32] <= mem_rd; // Kx
        else if(cnt == 17) K_reg[95:64] <= mem_rd; // Ky
        else if(cnt == 19) K_reg[128:96] <= { 1'b0, mem_rd }; // Ky
        else if(cnt == 21) M_reg[31:00] <= mem_rd; // Mx
        else if(cnt == 23) M_reg[63:32] <= mem_rd; // Mx
        else if(cnt == 25) M_reg[95:64] <= mem_rd; // My
        else if(cnt == 27) M_reg[128:96] <= { 1'b0, mem_rd }; // My
    end
    CAL_C1_rG: begin
        if(sc_mul_done) C1_reg <= sc_mul_R;
    end
    CAL_C2_rK: begin
        if(sc_mul_done) C2_reg <= sc_mul_R;
    end
    CAL_C2_M_add_rK: begin
        if(alu_done) C2_reg <= alu_R;
    end
    DECRYPT_INIT : begin
        if(cnt == 1) k_r_reg[31:0] <= mem_rd; // k
        else if(cnt == 3) k_r_reg[63:32] <= mem_rd; // k
        else if(cnt == 5) C1_reg[31:00] <= mem_rd; // C1x
        else if(cnt == 7) C1_reg[63:32] <= mem_rd; // C1x
        else if(cnt == 9) C1_reg[95:64] <= mem_rd; // C1y
        else if(cnt == 11) C1_reg[128:96] <= { 1'b0, mem_rd }; // C1y
        else if(cnt == 13) C2_reg[31:00] <= mem_rd; // C2x
        else if(cnt == 15) C2_reg[63:32] <= mem_rd; // C2x
        else if(cnt == 17) C2_reg[95:64] <= mem_rd; // C2y
        else if(cnt == 19) C2_reg[128:96] <= { 1'b0, mem_rd }; // C2y
    end
    CAL_M_kC1 : begin
        if(sc_mul_done) M_reg <= sc_mul_R;
    end
    CAL_M_C2_sub_kC1: begin
        if(alu_done) M_reg <= alu_R;
    end
    endcase
end


// sc_mul input control
assign sc_mul_a = k_r_reg;
assign sc_mul_alu_R = alu_R;
assign sc_mul_alu_done = alu_done;
always @(*) begin
    case (st)
    CAL_K_kG:  begin
        sc_mul_P = G_reg;
        sc_mul_en = prev_st != st;
    end
    CAL_C1_rG: begin
        sc_mul_P = G_reg;
        sc_mul_en = prev_st != st;
    end
    CAL_C2_rK: begin
        sc_mul_P = K_reg;
        sc_mul_en = prev_st != st;
    end
    CAL_M_kC1: begin
        sc_mul_P = C1_reg;
        sc_mul_en = prev_st != st;
    end
    default : begin
        sc_mul_P = 129'd0;
        sc_mul_en = 1'b0;
    end
    endcase
end

// mem output control
always @(*) begin
    case (st)
    IDLE: begin
        if(nst != st) begin
            mem_wen = 1'b1;
            mem_wd = 31'd0;
            mem_a = done_mem_addr;
        end
        else begin
            mem_wen = 1'b0;
            mem_wd = 31'd0;
            mem_a = 0;
        end
    end
    GEN_KEY_INIT: begin
        mem_wen = 1'b0;
        mem_wd = 31'd0;
        if(cnt < 2) mem_a = k_mem_addr;
        else if(cnt < 4) mem_a = k_mem_addr + 4;
        else if(cnt < 6) mem_a = Gx_mem_addr;
        else if(cnt < 8) mem_a = Gx_mem_addr + 4;
        else if(cnt < 10) mem_a = Gy_mem_addr;
        else if(cnt < 12) mem_a = Gy_mem_addr + 4;
        else mem_a = 0;
    end
    STORE_K: begin
        mem_wen = 1'b1;
        if(cnt == 0) begin
            mem_a = Kx_mem_addr;
            mem_wd = K_reg[31:0];
        end
        else if(cnt == 1) begin
            mem_a = Kx_mem_addr + 4;
            mem_wd = K_reg[63:32];
        end
        else if(cnt == 2) begin
            mem_a = Ky_mem_addr;
            mem_wd = K_reg[95:64];
        end
        else begin
            mem_a = Ky_mem_addr + 4;
            mem_wd = K_reg[127:96];
        end
    end
    ENCRYPT_INIT: begin
        mem_wen = 1'b0;
        mem_wd = 64'd0;
        if(cnt < 2) mem_a = r_mem_addr;
        else if(cnt < 4) mem_a = r_mem_addr + 4;
        else if(cnt < 6) mem_a = Gx_mem_addr;
        else if(cnt < 8) mem_a = Gx_mem_addr + 4;
        else if(cnt < 10) mem_a = Gy_mem_addr;
        else if(cnt < 12) mem_a = Gy_mem_addr + 4;
        else if(cnt < 14) mem_a = Kx_mem_addr;
        else if(cnt < 16) mem_a = Kx_mem_addr + 4;
        else if(cnt < 18) mem_a = Ky_mem_addr;
        else if(cnt < 20) mem_a = Ky_mem_addr + 4;
        else if(cnt < 22) mem_a = Mx_mem_addr;
        else if(cnt < 24) mem_a = Mx_mem_addr + 4;
        else if(cnt < 26) mem_a = My_mem_addr;
        else if(cnt < 28) mem_a = My_mem_addr + 4;
        else mem_a = 0;
    end
    STORE_C1C2: begin
        mem_wen = 1'b1;
        if(cnt == 0) begin
            mem_a = C1x_mem_addr;
            mem_wd = C1_reg[31:0];
        end
        else if(cnt == 1) begin
            mem_a = C1x_mem_addr + 4;
            mem_wd = C1_reg[63:32];
        end
        else if(cnt == 2) begin
            mem_a = C1y_mem_addr;
            mem_wd = C1_reg[95:64];
        end
        else if(cnt == 3) begin
            mem_a = C1y_mem_addr + 4;
            mem_wd = C1_reg[127:96];
        end
        else if(cnt == 4) begin
            mem_a = C2x_mem_addr;
            mem_wd = C2_reg[31:0];
        end
        else if(cnt == 5) begin
            mem_a = C2x_mem_addr + 4;
            mem_wd = C2_reg[63:32];
        end
        else if(cnt == 6) begin
            mem_a = C2y_mem_addr;
            mem_wd = C2_reg[95:64];
        end
        else begin
            mem_a = C2y_mem_addr + 4;
            mem_wd = C2_reg[127:96];
        end
    end
    DECRYPT_INIT : begin
        mem_wen = 1'b0;
        mem_wd = 64'd0;
        if(cnt < 2) mem_a = k_mem_addr;
        else if(cnt < 4) mem_a = k_mem_addr + 4;
        else if(cnt < 6) mem_a = C1x_mem_addr;
        else if(cnt < 8) mem_a = C1x_mem_addr + 4;
        else if(cnt < 10) mem_a = C1y_mem_addr;
        else if(cnt < 12) mem_a = C1y_mem_addr + 4;
        else if(cnt < 14) mem_a = C2x_mem_addr;
        else if(cnt < 16) mem_a = C2x_mem_addr + 4;
        else if(cnt < 18) mem_a = C2y_mem_addr;
        else if(cnt < 20) mem_a = C2y_mem_addr + 4;
        else mem_a = 0;
    end
    STORE_M: begin
        mem_wen = 1'b1;
        if(cnt == 0) begin
            mem_a = Mx_mem_addr;
            mem_wd = M_reg[31:0];
        end
        else if(cnt == 1) begin
            mem_a = Mx_mem_addr + 4;
            mem_wd = M_reg[63:32];
        end
        else if(cnt == 2) begin
            mem_a = My_mem_addr;
            mem_wd = M_reg[95:64];
        end
        else begin
            mem_a = My_mem_addr + 4;
            mem_wd = M_reg[127:96];
        end
    end
    DONE : begin
        mem_wen = 1'b1;
        mem_a = done_mem_addr;
        mem_wd = 32'd1;
    end
    default:  begin
        mem_wen = 1'b0;
        mem_wd = 32'd0;
        mem_a = 0;
    end
    endcase
end

// alu output control
always @(*) begin
    case (st)
    CAL_K_kG, CAL_C1_rG, CAL_C2_rK, CAL_M_kC1: begin
        alu_P = sc_mul_alu_P;
        alu_Q = sc_mul_alu_Q;
        alu_op = sc_mul_alu_op;
        alu_en = sc_mul_alu_en;
    end
    CAL_C2_M_add_rK: begin
        alu_P = M_reg;
        alu_Q = C2_reg;
        alu_op = ADD_ALU_OP;
        alu_en = prev_st != st;
    end
    CAL_M_C2_sub_kC1: begin
        alu_P = C2_reg;
        alu_Q = M_reg;
        alu_op = SUB_ALU_OP;
        alu_en = prev_st != st;
    end
    endcase
end

endmodule







module scalar_multipler (
    input clk,
    input rst,
    input [63:0] a,
    input [128:0] P,
    output [128:0] R,
    input sc_mul_en,
    output sc_mul_done,
    output [128:0] alu_P,
    output [128:0] alu_Q,
    input [128:0] alu_R,
    output [1:0] alu_op,
    output alu_en,
    input alu_done
);
    
parameter WAIT = 3'd0;
parameter INIT = 3'd1;
parameter DOUBLE = 3'd2;
parameter ADD = 3'd3;
parameter NEXT_ITER = 3'd4;
parameter OUT = 3'd5;

// to be done
parameter ADD_ALU_OP = 2'b00;
parameter DOUBLE_ALU_OP = 2'b10;

reg [2:0] st, nst, prev_st;
reg [6:0] cnt;
reg [63:0] a_reg;
reg [128:0] P_reg;
reg [128:0] R_reg;

// state machine
always @(posedge clk or negedge rst) begin
    if(~rst) begin
        st <= WAIT; 
        prev_st <= WAIT; 
    end
    else begin
        st <= nst;
        prev_st <= st;
    end
end
always @(*) begin
    case (st)
    WAIT: nst = sc_mul_en ? INIT : WAIT;
    INIT: nst = DOUBLE;
    DOUBLE: nst = ~alu_done ? DOUBLE : a_reg[cnt] ? ADD : NEXT_ITER;
    ADD: nst = ~alu_done ? ADD : NEXT_ITER;
    NEXT_ITER: nst = cnt != 0 ? DOUBLE : OUT;
    OUT: nst = WAIT;
    default: nst = WAIT;
    endcase
end

// registers (cnt, a_reg, P_reg, R_reg)
always @(posedge clk) begin
    case (st)
    INIT: begin
        cnt <= 63;
        a_reg <= a;
        P_reg <= P;
        R_reg <= { 1'b1, 128'b0 };
    end
    DOUBLE, ADD: begin
        if(alu_done) R_reg <= alu_R;
    end
    NEXT_ITER: begin
        cnt <= cnt - 1;        
    end
    endcase
end


// input & output logic
assign R = R_reg;
assign sc_mul_done = st == OUT;
assign alu_P = R_reg;
assign alu_Q = st == ADD ? P_reg : R_reg;
assign alu_op = st == ADD ? ADD_ALU_OP : DOUBLE_ALU_OP;
assign alu_en = (st == DOUBLE || st == ADD) && (st != prev_st);


endmodule