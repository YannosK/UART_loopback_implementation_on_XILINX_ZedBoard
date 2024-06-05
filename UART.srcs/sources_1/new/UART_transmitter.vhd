library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_transmitter is
    Port
    (
        clock      : in  std_logic;
        baud_ref   : in  std_logic;
        reset      : in  std_logic;
        Tx_write   : in  std_logic;
        Tx_Ready   : out std_logic;                     -- in from the user
        -- Tx_Data    : in  std_logic_vector(7 downto 0);  -- this is what was asked of us, but I do not see any way for data to be inserted in parallel
        Tx_Data    : in  std_logic;
        TxD        : out std_logic
    );
end UART_transmitter;

architecture Behavioral of UART_transmitter is

    component fifo_generator_0 IS
      PORT (
        clk : IN STD_LOGIC;
        srst : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
      );
    END component fifo_generator_0;

    signal count        : integer := 0;
    signal SIPO_full    : std_logic := 'X';     -- if '1' SIPO content can be passed to FIFO
    signal stop_check   : std_logic := 'X';     -- if '1' stop bit was correct
    signal FIFO_ready   : std_logic := 'X';     -- if '1' FIFO just emptied out

    type FSM_states is 
    (
        TX_idle,
        TX_wait_to_write,
        TX_write_SIPO,
        TX_stop_check,
        TX_wait_to_send
    );
    
    signal current_state    : FSM_states;
    signal next_state       : FSM_states;

    begin

        state_reg: process (clock) is
            begin
                if rising_edge(clock) then
                    if reset = '1' then
                        current_state <= TX_idle;
                    else
                        current_state <= next_state;
                    end if;
                end if;
        end process state_reg;

        state_logic: process (clock, current_state) is
            begin
                case current_state is
                    when TX_idle =>
                         -- HAVE NOT UNDERSTOOD THE PROCESS
                        if falling_edge(TX_Data) then
                            next_state <= TX_wait_to_write;
                        else
                            next_state <= TX_idle;
                        end if;
                    when TX_wait_to_write =>
                        if count = 16 and baud_ref = '1' then
                            next_state <= TX_write_SIPO;
                        else
                            next_state <= TX_wait_to_write;
                        end if;
                    when TX_write_SIPO =>
                        if SIPO_full = '1' then
                            next_state <= TX_stop_check;
                        else
                            next_state <= TX_write_SIPO;
                        end if;
                    when TX_stop_check =>
                        if stop_check = '1' then
                            next_state <= TX_wait_to_send;
                        else
                            next_state <= TX_idle;
                        end if;
                    when TX_wait_to_send =>
                        if FIFO_ready = '1' then
                            next_state <= TX_idle;
                        else
                            next_state <= TX_wait_to_send;
                        end if;
                    when others =>
                        next_state <= TX_idle;
                end case;
        end process state_logic;

        -- take_sample: process (baud_ref) is
        --     begin
        --         if count = 16 then
        --             count <= 0;
        --         else
        --             count <= count + 1;
        --         end if;
        -- end process take_sample;

end Behavioral;
