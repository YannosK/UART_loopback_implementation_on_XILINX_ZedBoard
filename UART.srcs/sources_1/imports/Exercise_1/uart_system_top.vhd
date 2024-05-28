library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- Option 1 for Zedboard validation/demonstration AND simulation/debug: Loopback in User Data/Control side
-- Option 2 for simulation/debug: Loopback in Rx-Tx side
--        Connect UART rx output to tx input.
--    Make available at system level the User data/control I/F (Tx_Write, Tx_Data, Tx_Ready, Rx_Read, Rx_Data, Rx_Valid)
--        Simulate user writes to UART Tx FIFO (Tx_Write, Tx_Data, Tx_Ready I/F)
--        Validate user reads to UART Rx FIFO (Rx_Read, Rx_Data, Rx_Valid I/F)

-- The following code implements Option1 (loopback in User Data/Control side) that will be validated/demonstrated in Zedboard using a PC with Terminal software
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

--  component your_fifo
--    port (
--     -- ...
--      );
--  end component;

  begin
--   UART_inst : UART
--     generic map( 
--      --    Pass baud rate as generic to UART (actually to the baud generator sub-unit of UART)
--       )
--     port map (
--      -- ...
--       );
  
--    loopback_buffer : your_fifo
--      port map(
--       -- Connect FIFO to the UART User Data/Control I/F 
--       -- ...
--        );
end Behavioral;
