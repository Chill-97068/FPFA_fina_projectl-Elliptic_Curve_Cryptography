library verilog;
use verilog.vl_types.all;
entity \MOD\ is
    generic(
        times           : integer := 65;
        dandsize        : integer := 128;
        diorsize        : integer := 64;
        qsize           : integer := 65;
        stage_num       : integer := 1
    );
    port(
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        a               : in     vl_logic_vector(127 downto 0);
        a_sign          : in     vl_logic;
        done            : out    vl_logic;
        result          : out    vl_logic_vector(63 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of times : constant is 1;
    attribute mti_svvh_generic_type of dandsize : constant is 1;
    attribute mti_svvh_generic_type of diorsize : constant is 1;
    attribute mti_svvh_generic_type of qsize : constant is 1;
    attribute mti_svvh_generic_type of stage_num : constant is 1;
end \MOD\;
