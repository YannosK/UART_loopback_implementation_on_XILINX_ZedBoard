library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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

    signal count    : integer := 0;

    begin

        -- take_sample: process (baud_ref) is
        --     begin
        --         if count = 16 then
        --             count <= 0;
        --         else
        --             count <= count + 1;
        --         end if;
        -- end process take_sample;

end Behavioral;
