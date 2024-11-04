----------------------------------------------------------------------------------
-- Takes en_16x_baud as reference and counts up from 1 to 8 and 15
-- To use the counter signal 'start' must remain '1'
-- If counter reaches 16 it rolls back to 1
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baud16_counter is
    port
    (
        baud_clk    : in std_logic;
        reset       : in std_logic;
        start       : in std_logic;     -- must be '1' to use counter. In a way it is like a synchronous reset
        half_ready  : out std_logic;    -- counter counted to 8
        ready       : out std_logic     -- counter counted to 15
    );
end baud16_counter;

architecture Behavioral of baud16_counter is

    signal count : positive := 1;

    begin

        count_up: process(baud_clk, reset) is
            begin
                if reset = '1' then
                    count <= 1;
                    half_ready <= '0';
                    ready <= '0';
                elsif rising_edge(baud_clk) then
                    if start = '1' then
                        if count = 8 then
                            half_ready <= '1';
                            ready <= '0';
                            count <= count + 1;
                        elsif count = 15 then
                            half_ready <= '0';
                            ready <= '1';
                            count <= count + 1;
                        elsif count = 16 then
                            half_ready <= '0';
                            ready <= '0';
                            count <= 1;
                        else
                            half_ready <= '0';
                            ready <= '0';
                            count <= count + 1;
                        end if;
                    else
                        count <= 1;
                        half_ready <= '0';
                        ready <= '0';
                    end if;
                end if;
        end process count_up;

end Behavioral;