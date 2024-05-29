library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baudrate_generator is
    generic (baudRate : integer := 115200);
    Port 
    (
        clock       : in std_logic;
        en_16x_baud : out std_logic;
        reset       : in std_logic
    );
end baudrate_generator;

architecture Behavioral of baudrate_generator is

    constant cycles : integer := 100000 / (16 * baudRate);
    signal count_up : integer := 0;

    begin

        baud_tick: process (clock) is
            begin
                if reset = '1' then
                    count_up <= 0;
                else
                    if rising_edge(clock) then
                        if count_up = cycles then
                            en_16x_baud <= '1';
                            count_up <= 0;
                        else
                            en_16x_baud <= '0';
                            count_up <= count_up + 1;
                        end if;
                    end if;
                end if;
        end process baud_tick;

end Behavioral;
