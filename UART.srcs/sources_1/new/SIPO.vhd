library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SIPO is
    generic (width : positive := 8);
    port
    (
        clk     : in std_logic;
        reset   : in std_logic;
        start   : in std_logic;
        ready   : out std_logic;
        s_in    : in std_logic;
        p_out   : out std_logic
    );
end SIPO;

architecture Behavioral of SIPO is

    signal full : integer := 0;

    begin

        -- SIPO_fill: process (reset, clk) is
        --     begin
        --         if reset = '1' then
        --             p_out <= (others => '0');
        --         else
        --             if start = '1' then
        --             end if;
        --         end if;
        -- end SIPO_fill;

end Behavioral;
