library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity UART_receiver is
    Port
    (
        Rx_Read    : in  std_logic;
        Rx_Valid   : out std_logic;
        Rx_Data    : out std_logic_vector(7 downto 0);
        baud_ref   : in  std_logic;
        RxD        : in  std_logic;
        reset      : in  std_logic
    );
end UART_receiver;

architecture Behavioral of UART_receiver is

    begin

end Behavioral;
