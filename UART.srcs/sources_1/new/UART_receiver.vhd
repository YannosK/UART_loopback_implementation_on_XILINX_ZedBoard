library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_receiver is
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
end UART_receiver;

architecture Behavioral of UART_receiver is

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

    type FSM_states is 
    (
        RX_idle,
        RX_start_check,
        RX_data_fetch,
        RX_stop_check,
        RX_FIFO_write
    );

    constant baud : integer := 115200;

    signal current_state    : FSM_states := RX_idle;
    signal next_state       : FSM_states;

    signal baud_count   : integer := 0;                 -- mod 16 counter to define sample moment
    signal fill_SIPO    : std_logic := '0';             -- signal to start filling SIPO from RxD. Connects to 'start' of SIPO
    signal filled_SIPO  : std_logic;                    -- signal that SIPO filled up
    signal data_internal: std_logic_vector(7 downto 0); -- data passed around from SIPO to FIFO
    signal full_FIFO    : std_logic;                    -- It is '1' if FIFO is completely filled. Connects to 'full' of FIFO
    signal write_FIFO   : std_logic;                    -- Set '1' to write to FIFO. Connects to 'wr_en' in FIFO
    signal empty_FIFO   : std_logic;                    -- If '1' FIFO is completely empty (no read allowed). Connects to 'empty' in FIFO

    begin
        
        -----------------------------------------------------------------------------------------------------------------
        -- modules
        -----------------------------------------------------------------------------------------------------------------

        RX_FIFO: fifo_generator_0 port map
                (
                    clk   => clock,
                    srst  => reset,
                    din   => data_internal,
                    wr_en => write_FIFO,
                    rd_en => RX_Read,           -- you have to make sure in the other side, that FIFO is not empty, and you don't read something empty
                    dout  => Rx_Data,
                    full  => full_FIFO,
                    empty => empty_FIFO
                );

        RX_SIPO: SIPO port map
                (
                    baud_clk => baud_ref,
                    reset    => reset,
                    start    => fill_SIPO,
                    ready    => filled_SIPO,
                    s_in     => RxD,
                    p_out    => data_internal
                );
        
        -----------------------------------------------------------------------------------------------------------------
        -- signals
        -----------------------------------------------------------------------------------------------------------------

        RX_Valid <= not empty_FIFO;

        -----------------------------------------------------------------------------------------------------------------
        -- processes
        -----------------------------------------------------------------------------------------------------------------

        state_reg: process (clock, reset) is
            begin
                if reset = '1' then
                    current_state <= RX_idle;
                else
                    if rising_edge(clock) then
                        current_state <= next_state;
                    end if;
                end if;
        end process state_reg;
        
        state_logic: process (clock, current_state, baud_ref, RxD, filled_SIPO, full_FIFO) is
            variable lock       : std_logic := '0';         -- I hope this works - not become '0' with every process activation
            begin
                case current_state is
                    when RX_idle        =>
                        fill_SIPO <= '0';
                        write_FIFO <= '0';                  -- WARNING: somehow a latch is produced
                        baud_count <= 0;
                        if RxD = '0' then
                            next_state <= RX_start_check;
                        else
                            next_state <= RX_idle;
                        end if;
                    when RX_start_check =>
                        if baud_ref = '1' and lock = '0' then
                            lock := '1';
                            if baud_count = 7 then
                                baud_count <= 0;
                                if RxD = '0' then
                                    lock := '0';
                                    next_state <= RX_data_fetch;
                                else
                                    lock := '0';
                                    next_state <= RX_idle;
                                end if;
                            else
                                baud_count <= baud_count + 1;
                                next_state <= RX_start_check;
                            end if;
                        elsif baud_ref = '0' and lock ='1' then
                            lock := '0';
                            next_state <= RX_start_check;
                        else
                            next_state <= RX_start_check;
                        end if;
                    when RX_data_fetch  =>
                        fill_SIPO <= '1';
                        if filled_SIPO = '1' then
                            next_state <= RX_stop_check;
                        else
                            next_state <= RX_data_fetch;
                        end if;
                    when RX_stop_check  =>                      -- ASSUMING: only 1 stop bit
                        if baud_ref = '1' and lock = '0' then
                            lock := '1';
                            if baud_count = 15 then
                                baud_count <= 0;
                                if RxD = '1' then
                                    lock := '0';
                                    next_state <= RX_FIFO_write;
                                else
                                    lock := '0';
                                    next_state <= RX_idle;
                                end if;
                            else
                                baud_count <= baud_count + 1;
                                next_state <= RX_stop_check;
                            end if;
                        elsif baud_ref = '0' and lock = '1' then
                            lock := '0';
                            next_state <= RX_stop_check;
                        else
                            next_state <= RX_stop_check;
                        end if;
                    when RX_FIFO_write  =>
                        if full_FIFO = '1' then
                            next_state <= RX_idle;
                        else
                            write_FIFO <= '1';               -- ATTENTION: not sure if it has enough time, for data to go through
                            next_state <= RX_idle;
                        end if;
                    when others =>
                        next_state <= RX_idle;
                end case;
        end process state_logic;

end Behavioral;
