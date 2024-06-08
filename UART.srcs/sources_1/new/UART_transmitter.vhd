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

    type FSM_states is 
    (
        TX_idle,
        TX_PISO_fill,
        TX_data_send
    );

    signal current_state    : FSM_states := TX_idle;
    signal next_state       : FSM_states;

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

        state_reg: process (clock, reset) is
            begin
                if reset = '1' then
                    current_state <= TX_idle;
                else
                    if rising_edge(clock) then
                        current_state <= next_state;
                    end if;
                end if;
        end process state_reg;
        
        -- state_logic: process (current_state, half_ready, ready, RxD, filled_SIPO, full_FIFO) is
        state_logic: process (current_state, empty_FIFO) is
            begin
                case current_state is
                    when TX_idle        =>
                        if empty_FIFO = '0' then
                            next_state <= TX_PISO_fill;
                        else
                            next_state <= TX_idle;
                        end if;
                    when TX_PISO_fill   =>
                    when TX_data_send   =>
                    when others =>
                        next_state <= TX_idle;
                end case;
        end process state_logic;


end Behavioral;
