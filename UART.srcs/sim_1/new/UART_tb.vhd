library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.NUMERIC_STD.ALL;
USE std.env.all;

entity UART_tb is
end UART_tb;

architecture Behavioral of UART_tb is

    component UART is
        generic (baudRate : integer := 115200);
        port
        (
            clk_100MHz : in  std_logic;
            reset      : in  std_logic;

            -- User Data/Control side
            Rx_Read    : in  std_logic;
            Rx_Valid   : out std_logic;
            Rx_Data    : out std_logic_vector(7 downto 0);  -- off to the user
            Tx_write   : in  std_logic;
            Tx_Ready   : out std_logic;                     -- in from the user
            Tx_Data    : in  std_logic_vector(7 downto 0);

            -- Serial Transmission side
            RxD : in  std_logic;
            TxD : out std_logic
        );
    end component UART;

    signal clk_100MHz : std_logic;
    signal reset      : std_logic;
    signal Rx_Read    : std_logic;
    signal Rx_Valid   : std_logic;
    signal Rx_Data    : std_logic_vector(7 downto 0);
    signal Tx_write   : std_logic;
    signal Tx_Ready   : std_logic;
    signal Tx_Data    : std_logic_vector(7 downto 0);
    signal RxD        : std_logic;
    signal TxD        : std_logic;

    constant baud       : integer := 115200;
    constant clk_period : time := 10 ns;

    begin

        uut: UART generic map (baudRate => baud)
            port map
            (
                clk_100MHz => clk_100MHz, 
                reset      => reset, 
                Rx_Read    => Rx_Read,   
                Rx_Valid   => Rx_Valid,     
                Rx_Data    => Rx_Data, 
                Tx_write   => Tx_write,  
                Tx_Ready   => Tx_Ready, 
                Tx_Data    => Tx_Data, 
                RxD        => RxD,  
                TxD        => TxD      
            );

            clock_system: process is
                begin
                    clk_100MHz <= '1';
                    wait for clk_period/2;
                    clk_100MHz <= '0';
                    wait for clk_period/2;
            end process clock_system;

            testbench: process is
                begin
            end process testbench;

end Behavioral;
