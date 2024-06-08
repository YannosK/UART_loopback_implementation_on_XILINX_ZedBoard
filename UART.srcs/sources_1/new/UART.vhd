library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity UART is
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
end entity UART;

architecture Behavioral of UART is

    component UART_receiver is
        Port
        (
            clock      : in  std_logic;
            reset      : in  std_logic;
            baud_ref   : in  std_logic;
            Rx_Read    : in  std_logic;
            Rx_Valid   : out std_logic;
            Rx_Data    : out std_logic_vector(7 downto 0);
            RxD        : in  std_logic
        );
    end component UART_receiver;

    component UART_transmitter is
        Port
        (
            clock      : in  std_logic;
            reset      : in  std_logic;
            baud_ref   : in  std_logic;
            Tx_write   : in  std_logic;
            Tx_Data    : in  std_logic_vector(7 downto 0);
            Tx_Ready   : out std_logic;
            TxD        : out std_logic
        );
    end component UART_transmitter;
    
    component baudrate_generator is
        generic (baudRate : integer := 115200);
        Port 
        (
            clock       : in std_logic;
            en_16x_baud : out std_logic;
            reset       : in std_logic
        );
    end component baudrate_generator;
    
    signal baudrate16 : std_logic;
    
    begin

        receiver: UART_receiver port map
            (
                clock    => clk_100MHz,
                reset    => reset,
                baud_ref => baudrate16, 
                Rx_Read  => Rx_Read,
                Rx_Valid => Rx_Valid,
                Rx_Data  => Rx_Data,
                RxD      => RxD      
            );
        
        transmitter: UART_transmitter port map
            (
                clock    => clk_100MHz,
                reset    =>
                baud_ref =>
                Tx_write =>
                Tx_Data  =>
                Tx_Ready =>
                TxD      =>
            );

        baud16_generator: baudrate_generator
            generic map
            (
                baudRate => baudRate
            )
            port map
            (
                clock => clk_100MHz,
                en_16x_baud => baudrate16,
                reset => reset
            );

end Behavioral;
