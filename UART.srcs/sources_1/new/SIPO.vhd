-------------------------------------------------------------------------------------------------------------------------------------
-- Serial Input - Parallel Output register of width bits
--
-- Uses the baud16_generator as clock
-- With proper signals it can take and store samples sequentially, like a shift register, every 16 baud16 ticks
-- This way it effectively samples at a tick precisely in the baud frequency
--
-- Uses some control signals:
--  + ready (out): signals that SIPO is empty and ready to be written
--  + start (in): when set to '1' SIPO fills up, until full. As long as it is full and it remains '1', data are available at p_out
--  + reset (in): resets every process going on
-------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SIPO is
    generic (width : positive := 8);
    port
    (
        baud_clk: in std_logic;         -- this must come from baud
        reset   : in std_logic;
        start   : in std_logic;         -- start filling the SIPO, must remain '1' or SIPO will not fill. If it fills fetch data when ready = '1', if you set start = '0' SIPO empties and waits new data
        ready   : out std_logic;        -- signal that SIPO is ready. If you want to fetch 
        s_in    : in std_logic;
        p_out   : out std_logic_vector(width-1 downto 0)
    );
end SIPO;

architecture Behavioral of SIPO is

    signal fill         : integer := 0;         -- counter to count if SIPO is filled
    signal baud_count   : integer := 0;         -- mod 16 counter to define sample moment
    signal baud_tick    : std_logic := '0';         -- mod 16 tick, that is defined by baud_count
    signal ready_int    : std_logic := '0';     -- if '1' SIPO is full and ready to read
    signal data_in      : std_logic := 'X';     -- internal signal to manage the incoming data
    signal shift_reg    : std_logic_vector(width-1 downto 0) := (others => '0'); -- internal signal to manage contents of SIPO

    begin

        ready <= ready_int;
        p_out <= shift_reg;
        data_in <= s_in;

        mod16_counter: process (reset, baud_clk) is
            begin
                if reset = '1' then
                    baud_count <= 0;
                    baud_tick <= '0';
                else
                    if rising_edge(baud_clk) then
                        if baud_count /= 15 then                -- ATTENTION: not sure if it must be 15 or 16
                            baud_count <= baud_count + 1;
                            baud_tick <= '0';
                        elsif baud_count = 1 then
                            baud_count <= 0;
                            baud_tick <= '1';
                        else
                            baud_tick <= '0';                   -- YOU HAVE TO SEE WHAT HAPPENS IN THAT CASE
                        end if;
                    end if;
                end if;

        end process mod16_counter;

        SIPO_fill: process (reset, baud_clk) is
            begin
                if reset = '1' then
                    fill <= 0;
                    ready_int <= '0';
                    shift_reg <= (others => '0');
                else
                    if start = '1' and ready_int = '0' and baud_tick = '1' then
                        if fill = width then
                            ready_int <= '1';
                            fill <= 0;
                        else
                            shift_reg <= data_in & shift_reg(width-1 downto 1);
                            fill <= fill + 1;
                        end if;
                    elsif start = '0' then
                        ready_int <= '0';
                        shift_reg <= (others => '0');
                    end if;                                 -- this if statement will probably produce a latch, but I think we want that
                end if;
        end process SIPO_fill;

end Behavioral;
