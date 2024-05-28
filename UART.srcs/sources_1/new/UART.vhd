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

    signal baudrate16 : std_logic;

    component UART_receiver is
        Port
        (
            Rx_Read    : in  std_logic;
            Rx_Valid   : out std_logic;
            Rx_Data    : out std_logic_vector(7 downto 0);
            baud_ref   : in  std_logic;
            RxD        : in  std_logic;
            reset      : in  std_logic
        );
    end component UART_receiver;

    component UART_transmitter is
        Port
        (
            Tx_write   : in  std_logic;
            Tx_Ready   : out std_logic;                     -- in from the user
            Tx_Data    : in  std_logic_vector(7 downto 0);
            baud_ref   : in  std_logic;
            TxD        : out std_logic;
            reset      : in  std_logic
        );
    end component    UART_transmitter;
    
    component baudrate_generator is
        generic (baudRate : integer := 115200);
        Port 
        (
            clock       : in std_logic;
            en_16x_baud : out std_logic
        );
    end component baudrate_generator;
    
    begin

        receiver: UART_receiver port map
            (
                Rx_Read  => Rx_Read,
                Rx_Valid => Rx_Valid,
                Rx_Data  => Rx_Data,
                baud_ref => baudrate16,
                RxD      => RxD,
                reset    => reset
            );
        
        transmitter: UART_transmitter port map
            (
                Tx_write => Tx_write,
                Tx_Ready => Tx_Ready,
                Tx_Data  => Tx_Data,
                baud_ref => baudrate16,
                TxD      => TxD,
                reset    => reset
            );

        baud16_generator: baudrate_generator
            generic map
            (
                baudRate => baudRate
            )
            port map
            (
                clock => clk_100MHz,
                en_16x_baud => baudrate16
            );

end Behavioral;
