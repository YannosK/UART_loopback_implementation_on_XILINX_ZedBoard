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

    -- constant cycles : integer := 100000 / (16 * baudRate); -- This does not seem to work
    signal cycles   : std_logic_vector(12 downto 0);
    signal count_up : integer := 0;

    begin

        -- cycles <= std_logic_vector(to_unsigned((100000 / (16 * baudRate)), cycles'length)); -- WHY DOESN'T IT WORK???

        cycles(5 downto 0) <= "110110";
        cycles(12 downto 6) <= (others => '0'); 

        baud_tick: process (clock) is
            begin
                if reset = '1' then
                    count_up <= 0;
                else
                    if rising_edge(clock) then
                        if count_up = to_integer(unsigned(cycles)) then
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
