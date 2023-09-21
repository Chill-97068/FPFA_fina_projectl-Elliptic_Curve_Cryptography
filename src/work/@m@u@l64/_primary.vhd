library verilog;
use verilog.vl_types.all;
entity MUL64 is
    generic(
        MUL             : vl_logic_vector(0 to 1) := (Hi0, Hi0);
        ADD             : vl_logic_vector(0 to 1) := (Hi0, Hi1);
        \DONE\          : vl_logic_vector(0 to 1) := (Hi1, Hi0)
    );
    port(
        clk             : in     vl_logic;
        mul1            : in     vl_logic_vector(63 downto 0);
        mul2            : in     vl_logic_vector(63 downto 0);
        mul1_sign       : in     vl_logic;
        mul2_sign       : in     vl_logic;
        enable          : in     vl_logic;
        result          : out    vl_logic_vector(127 downto 0);
        done            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MUL : constant is 1;
    attribute mti_svvh_generic_type of ADD : constant is 1;
    attribute mti_svvh_generic_type of \DONE\ : constant is 1;
end MUL64;
