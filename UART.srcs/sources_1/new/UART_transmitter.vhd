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

    component reg_8bit is
        port
        (
            clk     : in std_logic;
            reset   : in std_logic;
            we      : in std_logic;
            d_in    : in std_logic_vector (7 downto 0);
            d_out   : out std_logic_vector (7 downto 0)
        );
    end component reg_8bit;

    type FSM_states is 
    (
        TX_idle,
        TX_data_send
    );

    signal current_state    : FSM_states := TX_idle;
    signal next_state       : FSM_states;

    signal start_counter: std_logic := '0';             -- signal to start the baud16 counter module
    signal half_ready   : std_logic;                    -- signal that the counter counted to 8 
    signal ready        : std_logic;                    -- signal that the counter counted to 16
    signal step         : integer := 0;                 -- signal to see the step of the transmission
    signal reg_data     : std_logic := '0';             -- when '1' it registers data from FIFO to internal register
    signal FIFO_out     : std_logic_vector(7 downto 0); -- data passed around from FIFO to internal register
    signal data_internal: std_logic_vector(7 downto 0); -- data output of internal register
    signal data_out     : std_logic := '1';             -- signal to manage the serial ouput of TX. Connects to TxD
    signal full_FIFO    : std_logic;                    -- It is '1' if FIFO is completely filled. Connects to 'full' of FIFO
    signal read_FIFO    : std_logic := '0';             -- Set '1' to read from FIFO. Connects to 'rd_en' in FIFO. Only read if not empty
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
                    rd_en => read_FIFO,
                    dout  => FIFO_out,
                    full  => full_FIFO,
                    empty => empty_FIFO
                );

        TX_counter: baud16_counter port map
                (
                    baud_clk   => baud_ref,
                    reset      => reset,
                    start      => start_counter,
                    half_ready => half_ready,
                    ready      => ready
                );

        TX_register: reg_8bit port map
                (
                    clk   => clock,
                    reset => reset,
                    we    => reg_data,
                    d_in  => FIFO_out,
                    d_out => data_internal
                );

        -----------------------------------------------------------------------------------------------------------------
        -- signals
        -----------------------------------------------------------------------------------------------------------------

        TX_Ready <= not full_FIFO;
        TxD <= data_out;

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
        
        state_logic: process (current_state, empty_FIFO, ready) is
            begin
                read_FIFO <= '0';
                reg_data <= '0';
                data_out <= '1';
                step <= 0;
                start_counter <= '0';
                case current_state is
                    when TX_idle =>
                        if empty_FIFO = '0' then
                            read_FIFO <= '1';
                            reg_data <= '1';
                            data_out <= '0';
                            next_state <= TX_data_send;
                        else
                            next_state <= TX_idle;
                        end if;
                    when TX_data_send =>
                        data_internal <= data_internal;
                        start_counter <= '1';
                        if ready = '1' then
                            if step = 8 then
                                data_out <= '1';
                                start_counter <= '0';       -- not sure if needed
                                next_state <= TX_idle;
                            else
                                data_out <= data_internal(step);
                                step <= step + 1;
                                start_counter <= '0';       -- not sure if needed
                                next_state <= TX_data_send;
                            end if;
                        else
                            data_out <= data_internal(step); -- not sure if needed
                            next_state <= TX_data_send;
                        end if;
                    when others =>
                        next_state <= TX_idle;
                end case;
        end process state_logic;


end Behavioral;
