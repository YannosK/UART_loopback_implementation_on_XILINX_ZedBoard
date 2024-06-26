library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_transmitter is
    Port
    (
        clock : in std_logic;
        reset : in std_logic;
        Tx_write : in std_logic;
        Tx_Data : in std_logic_vector(7 downto 0);
        Tx_Ready : out std_logic;
        TxD : out std_logic
    );
end UART_transmitter;

architecture Behavioral of UART_transmitter is

    component fifo_generator_0 is
        port 
        (
            clk : IN STD_LOGIC;
            srst : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC
        );
    end component fifo_generator_0;

    type FSM_states is 
    (
        TX_idle,
        TX_send_start_bit,
        TX_data_send,
        TX_send_stop_bit
    );

    signal state_reg : FSM_states := TX_idle;
    signal data_internal: std_logic_vector(7 downto 0); -- internal shift register  WARNING: IT IS NOT EXACTLY A REGISTER
    signal read_FIFO : std_logic := '0'; -- Set '1' to read from FIFO. Connects to 'rd_en' in FIFO. Only read if not empty
    signal TX_Start : std_logic; -- initiate the transmitter when at least one data sample is available
    signal full_FIFO : std_logic; -- It is '1' if FIFO is completely filled. Connects to 'full' of FIFO
    signal empty_FIFO : std_logic; -- If '1' FIFO is completely empty (no read allowed). Connects to 'empty' in FIFO

    begin

    -----------------------------------------------------------------------------------------------------------------
    -- modules
    -----------------------------------------------------------------------------------------------------------------
    
    TX_FIFO: fifo_generator_0 port map
    (
        clk => clock,
        srst => reset,
        din => TX_Data,
        wr_en => TX_write, -- write immediately data to FIFO when issued. Save one cycle in the current design
        rd_en => read_FIFO,
        dout => data_internal, -- write immediately data to shift register. Save one clock cycle.
        full => full_FIFO,
        empty => empty_FIFO
    );

    -----------------------------------------------------------------------------------------------------------------
    -- signals
    -----------------------------------------------------------------------------------------------------------------

    TX_Ready <= not (full_FIFO);
    TX_Start <= not (empty_FIFO); -- FIFO content used as ignition for transmission
    
    -----------------------------------------------------------------------------------------------------------------
    -- processes
    -----------------------------------------------------------------------------------------------------------------
    
    -- use clock within the sensitivity list of your state logic process to
    -- activate the process on every clock tick.

    state_logic: process (reset, clock) is
        variable counter : integer := 0;	-- baud counter
        variable bitindex: integer := 0;	-- bit counter within the shift register
        begin
            if reset = '1' then 
            	state_reg <= TX_idle;
                TxD <= '1';
            	counter := 0;
            	bitindex := 0;
            	read_FIFO <= '0';
            elsif rising_edge(clock) then 
                -- make sure the FIFOs read channel is deactivated
                read_FIFO <= '0';	
                case state_reg is
                    when TX_idle =>
                        bitindex := 0;
                        read_FIFO <= '0'; -- no need to read FIFO here since it is FWFT. We do that on another state to save 2 cycles
                        if TX_start = '1' then
                            counter := 1; -- You will miss one cycle just to get to the other state
                            -- SHOULDN'T WE ALSO START THE START BIT WITH:
                            -- TxD <= '0';
                            state_reg <= TX_send_start_bit;
                        else 
                            TxD 	 <= '1';
                            counter := 0;
                            state_reg <= TX_idle;
                        end if;
                    when TX_send_start_bit =>
                        TxD <= '0';
                        bitindex := 0;
                        read_FIFO <= '0';
                        if counter = 15 then
                            counter := 0;
                            state_reg <= TX_data_send;
                        else
                            counter := counter + 1;
                            state_reg <= TX_send_start_bit;
                        end if;
                    when TX_data_send =>                -- data_internal seems unspecifies. It is FIFO's out. What does this mean?
                        TxD <= data_internal(bitindex); -- ISN'T THERE A PROBLEM THE FIRST TIME THAT WE HAVE NOT READ FIFO YET?
                        if counter = 15 then
                            counter := 0;
                            if bitindex < 7 then
                                bitindex := bitindex + 1;
                                state_reg <= TX_data_send;
                            else
                                bitindex := 0;
                                -- here you need to read the next data sample from FIFO
                                -- remember your FIFO is FWFT!
                                read_FIFO <= '1';
                                state_reg <= TX_send_stop_bit;
                            end if;
                        else                        -- UNSPECIFIED BIT INDEX??
                            counter := counter + 1;
                            state_reg <= TX_data_send;
                        end if;
                    when TX_send_stop_bit =>
                        read_FIFO <= '0';
                        TxD <= '1';
                        bitindex := 0;
                        if counter = 15 then 
                            counter := 0;
                            state_reg <= TX_idle;
                        else
                            counter := counter + 1;
                            state_reg <= TX_send_stop_bit;
                        end if;
                    when others =>
                        state_reg <= TX_idle;
                end case;
            end if;
    end process state_logic;
end Behavioral;