library verilog;
use verilog.vl_types.all;
entity ALU is
    generic(
        idle            : integer := 0;
        segment1        : integer := 1;
        segment2        : integer := 2;
        segment3        : integer := 3;
        segment4        : integer := 4;
        segment5        : integer := 5;
        segment6        : integer := 6;
        segment7        : integer := 7;
        segment8        : integer := 8;
        segment9        : integer := 9;
        segment10       : integer := 10;
        segment11       : integer := 11;
        segment12       : integer := 12;
        segment13       : integer := 13;
        segment14       : integer := 14;
        segment15       : integer := 15;
        segment16       : integer := 16;
        finish          : integer := 17
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        alu_en          : in     vl_logic;
        alu_P           : in     vl_logic_vector(128 downto 0);
        alu_Q           : in     vl_logic_vector(128 downto 0);
        alu_op          : in     vl_logic_vector(1 downto 0);
        alu_R           : out    vl_logic_vector(128 downto 0);
        alu_done        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of idle : constant is 1;
    attribute mti_svvh_generic_type of segment1 : constant is 1;
    attribute mti_svvh_generic_type of segment2 : constant is 1;
    attribute mti_svvh_generic_type of segment3 : constant is 1;
    attribute mti_svvh_generic_type of segment4 : constant is 1;
    attribute mti_svvh_generic_type of segment5 : constant is 1;
    attribute mti_svvh_generic_type of segment6 : constant is 1;
    attribute mti_svvh_generic_type of segment7 : constant is 1;
    attribute mti_svvh_generic_type of segment8 : constant is 1;
    attribute mti_svvh_generic_type of segment9 : constant is 1;
    attribute mti_svvh_generic_type of segment10 : constant is 1;
    attribute mti_svvh_generic_type of segment11 : constant is 1;
    attribute mti_svvh_generic_type of segment12 : constant is 1;
    attribute mti_svvh_generic_type of segment13 : constant is 1;
    attribute mti_svvh_generic_type of segment14 : constant is 1;
    attribute mti_svvh_generic_type of segment15 : constant is 1;
    attribute mti_svvh_generic_type of segment16 : constant is 1;
    attribute mti_svvh_generic_type of finish : constant is 1;
end ALU;
