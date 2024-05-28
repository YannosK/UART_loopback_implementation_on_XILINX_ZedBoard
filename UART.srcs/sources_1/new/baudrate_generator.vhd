library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity baudrate_generator is
    generic (baudRate : integer := 115200);
    Port 
    (
        clock       : in std_logic;
        en_16x_baud : out std_logic
    );
end baudrate_generator;

architecture Behavioral of baudrate_generator is

    begin

end Behavioral;
