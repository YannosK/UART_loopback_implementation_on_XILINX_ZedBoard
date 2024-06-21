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
        TX_send_start_bit,
        TX_data_send,
        TX_stop_bit
    );

    signal current_state    : FSM_states := TX_idle;
    signal next_state       : FSM_states;

    signal FIFO_out     : std_logic_vector(7 downto 0); -- data passed around from FIFO to internal register
    signal data_internal: std_logic_vector(7 downto 0); -- internal shift register
    signal full_FIFO    : std_logic;                    -- It is '1' if FIFO is completely filled. Connects to 'full' of FIFO
    signal read_FIFO    : std_logic := '0';             -- Set '1' to read from FIFO. Connects to 'rd_en' in FIFO. Only read if not empty
    signal write_FIFO   : std_logic := '0';             -- Set '1' to write to FIFO. Connects to 'wr_en' in FIFO. Only write if not full
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
                    wr_en => write_FIFO,
                    rd_en => read_FIFO,
                    dout  => FIFO_out,
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
        
        state_logic: process (current_state, TX_write, baud_ref) is
            variable counter : integer := 0;
            variable bitindex: integer := 0;
            begin
                case current_state is
                    when TX_idle =>
                        TxD <= '1';
                        counter := 0;
                        bitindex := 0;
                        if empty_FIFO = '0' and TX_write = '1' then
                            read_FIFO <= '1';
                            data_internal <= FIFO_out;                            
                            next_state <= TX_send_start_bit;
                        else
                            read_FIFO <= '0';
                            data_internal <= (others => '1');
                            next_state <= TX_idle;
                        end if;
                    when TX_send_start_bit =>
                        TxD <= '0';
                        bitindex := 0;
                        if rising_edge(baud_ref) then
                            counter := counter + 1;
                            if counter = 16 then
                                next_state <= TX_data_send;
                            end if;
                        else
                            next_state <= TX_send_start_bit;
                        end if;
                    when TX_data_send =>
                        TxD <= data_internal(bitindex);
                        if bitindex < 8 then
                            if rising_edge(baud_ref) then
                                counter := counter + 1;
                                if counter = 16 then
                                    bitindex := bitindex + 1;
                                end if;
                            else
                                next_state <= TX_send_start_bit;
                            end if;
                        end if;
                    when TX_stop_bit =>
                        TxD <= '0';
                        if rising_edge(baud_ref) then
                            counter := counter + 1;
                            if counter = 16 then
                                next_state <= TX_data_send;
                            end if;
                        else
                            next_state <= TX_send_start_bit;
                        end if;
                    when others =>
                        next_state <= TX_idle;
                end case;
        end process state_logic;


end Behavioral;
