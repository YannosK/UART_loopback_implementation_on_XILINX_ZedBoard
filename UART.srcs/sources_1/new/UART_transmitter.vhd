library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_transmitter is
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
end UART_transmitter;

architecture Behavioral of UART_transmitter is
    
    component fifo_generator_0 is
      port 
      (
        clk     : IN STD_LOGIC;
        srst    : IN STD_LOGIC;
        din     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en   : IN STD_LOGIC;
        rd_en   : IN STD_LOGIC;
        dout    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full    : OUT STD_LOGIC;
        empty   : OUT STD_LOGIC
      );
    end component fifo_generator_0;

    component SIPO is
        port
        (
            baud_clk: in std_logic;
            reset   : in std_logic;
            start   : in std_logic;
            ready   : out std_logic;
            s_in    : in std_logic;
            p_out   : out std_logic_vector(7 downto 0)
        );
    end component SIPO;

    component baud16_counter is
        port
        (
            baud_clk    : in std_logic;
            reset       : in std_logic;
            start       : in std_logic;
            half_ready  : out std_logic;
            ready       : out std_logic
        );
    end component baud16_counter;

    type FSM_states is 
    (
        RX_idle,
        RX_start_check,
        RX_data_fetch,
        RX_stop_check,
        RX_FIFO_write
    );

    -- signal start_counter: std_logic := '0';             -- signal to start the baud16 counter module
    -- signal half_ready   : std_logic;                    -- signal that the counter counted to 8 
    -- signal ready        : std_logic;                    -- signal that the counter counted to 16
    -- signal fill_SIPO    : std_logic := '0';             -- signal to start filling SIPO from RxD. Connects to 'start' of SIPO
    -- signal filled_SIPO  : std_logic;                    -- signal that SIPO filled up
    signal data_internal: std_logic_vector(7 downto 0); -- data passed around from FIFO to SIPO
    signal full_FIFO    : std_logic;                    -- It is '1' if FIFO is completely filled. Connects to 'full' of FIFO
    signal write_FIFO   : std_logic;                    -- Set '1' to write to FIFO. Connects to 'wr_en' in FIFO
    signal empty_FIFO   : std_logic;                    -- If '1' FIFO is completely empty (no read allowed). Connects to 'empty' in FIFO

    begin

        -----------------------------------------------------------------------------------------------------------------
        -- modules
        -----------------------------------------------------------------------------------------------------------------

        TX_FIFO: fifo_generator_0 port map
                (
                    clk   => clock,
                    srst  => reset,
                    din   => TX_Data,
                    wr_en => TX_write,
                    rd_en => write_FIFO,
                    dout  => data_internal,
                    full  => full_FIFO,
                    empty => empty_FIFO
                );
        
        -----------------------------------------------------------------------------------------------------------------
        -- signals
        -----------------------------------------------------------------------------------------------------------------

        TX_Ready <= not full_FIFO;

        -----------------------------------------------------------------------------------------------------------------
        -- processes
        -----------------------------------------------------------------------------------------------------------------



end Behavioral;
