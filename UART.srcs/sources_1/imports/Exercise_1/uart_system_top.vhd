library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity uart_system_top is
  port
  (
    clk_100MHz : in  std_logic;   -- added in constraints
    rst        : in  std_logic;
    RxD        : in  std_logic;
    TxD        : out std_logic
  );
end uart_system_top;

architecture Behavioral of uart_system_top is

  component UART
    generic(
      baudRate : integer := 115200
      );
    port(
      clk_100MHz : in  std_logic;
      reset      : in  std_logic;

      -- User Data/Control side
      Rx_Read    : in  std_logic;
      Rx_Valid   : out std_logic;
      Rx_Data    : out std_logic_vector(7 downto 0);
      Tx_write   : in  std_logic;
      Tx_Ready   : out std_logic;
      Tx_Data    : in  std_logic_vector(7 downto 0);

      -- Serial Transmission side
      RxD : in  std_logic;
      TxD : out std_logic);
  end component UART;

  signal data     : std_logic_vector(7 downto 0);
  signal TX_Ready : std_logic;
  signal TX_Write : std_logic := '0';
  signal RX_Valid : std_logic;
  signal RX_Read  : std_logic := '0';

  begin

    UART_module: UART port map
      (
        clk_100MHz => clk_100MHz,
        reset      => rst,
        Rx_Read    => RX_Read,
        Rx_Valid   => RX_Valid,
        Rx_Data    => data,
        Tx_write   => TX_Write,
        Tx_Ready   => TX_Ready,
        Tx_Data    => data,
        RxD        => RxD,
        TxD        => TxD
      );
    
    RX_Read <= RX_Valid and TX_Ready;
    TX_write <= TX_Ready and RX_Valid;

end Behavioral;
