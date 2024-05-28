library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity UART_transmitter is
    Port
    (
        Tx_write   : in  std_logic;
        Tx_Ready   : out std_logic;                     -- in from the user
        Tx_Data    : in  std_logic_vector(7 downto 0);
        baud_ref   : in  std_logic;
        TxD        : out std_logic;
        reset      : in  std_logic
    );
end UART_transmitter;

architecture Behavioral of UART_transmitter is

    begin

end Behavioral;
