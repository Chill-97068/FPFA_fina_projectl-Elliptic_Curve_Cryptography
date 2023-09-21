library verilog;
use verilog.vl_types.all;
entity INV_MOD is
    generic(
        MUL1            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        MOD1            : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        MUL2            : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        MOD2            : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        \DONE\          : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        enable          : in     vl_logic;
        t               : in     vl_logic_vector(63 downto 0);
        t_sign          : in     vl_logic;
        mod_done        : in     vl_logic;
        mod_result      : in     vl_logic_vector(63 downto 0);
        mul64_done      : in     vl_logic;
        mul64_result    : in     vl_logic_vector(127 downto 0);
        mod_enable      : out    vl_logic;
        mod_input       : out    vl_logic_vector(127 downto 0);
        mod_input_sign  : out    vl_logic;
        mul64_enable    : out    vl_logic;
        mul64_mul1      : out    vl_logic_vector(63 downto 0);
        mul64_mul2      : out    vl_logic_vector(63 downto 0);
        mul64_mul1_sign : out    vl_logic;
        mul64_mul2_sign : out    vl_logic;
        done            : out    vl_logic;
        result          : out    vl_logic_vector(63 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MUL1 : constant is 1;
    attribute mti_svvh_generic_type of MOD1 : constant is 1;
    attribute mti_svvh_generic_type of MUL2 : constant is 1;
    attribute mti_svvh_generic_type of MOD2 : constant is 1;
    attribute mti_svvh_generic_type of \DONE\ : constant is 1;
end INV_MOD;
