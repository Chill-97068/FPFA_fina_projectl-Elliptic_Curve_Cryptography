library verilog;
use verilog.vl_types.all;
entity ADD_DOUBLE is
    generic(
        idle            : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi0, Hi0, Hi0);
        segment1        : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi0, Hi0, Hi1);
        segment2        : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi0, Hi1, Hi0);
        segment3        : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi0, Hi1, Hi1);
        segment4        : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi1, Hi0, Hi0);
        segment5        : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi1, Hi0, Hi1);
        segment6        : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi1, Hi1, Hi0);
        segment7        : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi1, Hi1, Hi1);
        segment8        : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi0, Hi0, Hi0);
        segment9        : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi0, Hi0, Hi1);
        segment10       : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi0, Hi1, Hi0);
        segment11       : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi0, Hi1, Hi1);
        segment12       : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi1, Hi0, Hi0);
        segment13       : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi1, Hi0, Hi1);
        segment14       : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi1, Hi1, Hi0);
        segment15       : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi1, Hi1, Hi1);
        segment16       : vl_logic_vector(0 to 4) := (Hi1, Hi0, Hi0, Hi0, Hi0);
        finish          : vl_logic_vector(0 to 4) := (Hi1, Hi0, Hi0, Hi0, Hi1)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        enable          : in     vl_logic;
        p               : in     vl_logic_vector(128 downto 0);
        q               : in     vl_logic_vector(128 downto 0);
        T               : out    vl_logic_vector(128 downto 0);
        helpmul         : out    vl_logic;
        muldone         : in     vl_logic;
        mul_a           : out    vl_logic_vector(63 downto 0);
        neg_mul_a       : out    vl_logic;
        mul_b           : out    vl_logic_vector(63 downto 0);
        neg_mul_b       : out    vl_logic;
        mul_result      : in     vl_logic_vector(127 downto 0);
        helpmod         : out    vl_logic;
        moddone         : in     vl_logic;
        mod_a           : out    vl_logic_vector(127 downto 0);
        neg_mod_a       : out    vl_logic;
        mod_result      : in     vl_logic_vector(63 downto 0);
        helpinvmod      : out    vl_logic;
        invmoddone      : in     vl_logic;
        invmod_a        : out    vl_logic_vector(63 downto 0);
        neg_invmod_a    : out    vl_logic;
        invmod_result   : in     vl_logic_vector(63 downto 0);
        done            : out    vl_logic;
        op              : in     vl_logic_vector(1 downto 0);
        state           : out    vl_logic_vector(4 downto 0)
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
end ADD_DOUBLE;
