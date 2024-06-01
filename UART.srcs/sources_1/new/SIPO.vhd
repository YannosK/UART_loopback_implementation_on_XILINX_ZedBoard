library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SIPO is
    generic (width : positive := 8);
    port
    (
        clk     : in std_logic;         -- this must come from baud
        reset   : in std_logic;
        start   : in std_logic;         -- start filling the SIPO, must remain '1' or SIPO will not fill. If it fills fetch data when ready = '1', if you set start = '0' SIPO empties and waits new data
        ready   : out std_logic;        -- signal that SIPO is ready
        s_in    : in std_logic;
        p_out   : out std_logic_vector(width-1 downto 0)
    );
end SIPO;

architecture Behavioral of SIPO is

    signal fill         : integer := 0;         -- counter to count if SIPO is filled
    signal ready_int    : std_logic := '0';     -- if '1' SIPO is full and ready to read
    signal shift_reg    : std_logic_vector(width-1 downto 0) := (others => '0');

    begin

        ready <= ready_int;
        p_out <= shift_reg;

        SIPO_fill: process (reset, clk) is
            begin
                if reset = '1' then
                    p_out <= (others => '0');
                    ready_int <= '0';
                    fill <= 0;
                    shift_reg <= (others => '0');
                    p_out <= (others => '0');
                else
                    if start = '1' and ready_int = '0' then
                        if rising_edge(clk) then
                            if fill = width then
                                ready_int <= '1';
                                fill <= 0;
                            else
                                shift_reg <= s_in & shift_reg(width-1 downto 1);
                                fill <= fill + 1;
                            end if;
                        end if;
                    elsif start = '0' then
                        ready_int <= '0';
                        shift_reg <= (others => '0');
                    end if;
                end if;
        end process SIPO_fill;

end Behavioral;
