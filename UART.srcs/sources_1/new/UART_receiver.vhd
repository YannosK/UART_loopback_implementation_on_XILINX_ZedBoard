library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_receiver is
    port
    (
        clock : in std_logic;
        reset : in std_logic;
        RxD : in std_logic;
        RX_Read : in std_logic;
        RX_Valid : out std_logic;
        RX_Data : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of UART_receiver is 

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
        RX_idle,
        RX_receive_start_bit,
        RX_data_receive,
        RX_receive_stop_bit
    );

    signal state_reg : FSM_states := RX_idle;
    signal data_internal: std_logic_vector(7 downto 0); -- internal shift register 
    signal write_FIFO : std_logic := '0'; -- Used as signal to write to FIFO. Not allowed to write if FIFO is full. Connects to wr_en of FIFO
    signal full_FIFO : std_logic; -- It is '1' if FIFO is completely filled. Connects to 'full' of FIFO
    signal empty_FIFO : std_logic; -- If '1' FIFO is completely empty (no read allowed). Connects to 'empty' in FIFO

    begin
        
        Rx_valid <= not (empty_FIFO); 

        receive_fifo : fifo_generator_0
        port map 
        (
            clk => clock,
            srst => reset,
            din => data_internal, 
            wr_en => write_FIFO, 
            rd_en => RX_Read, 
            dout => RX_Data,
            full => full_FIFO, 
            empty => empty_FIFO
        );

        process(clock, reset)
            variable counter : integer := 0;
            variable bitindex : integer := 0;
            begin
                if(reset='1') then
                	state_reg <= RX_idle;
                	data_internal <= (others=>'0');
                	write_FIFO <= '0';
                	counter := 0;
                	bitindex := 0;
                elsif(rising_edge(clock)) then
                    write_FIFO <= '0';
                    case state_reg is
                        when RX_idle =>                 -- DO I need data_internal specified in each state?
                            if RxD='0' then
                                bitindex := 0;
                                counter := 1;
                                state_reg <= RX_receive_start_bit;
                            else
                                bitindex := 0;
                                counter := 0;
                                state_reg <= RX_idle;
                            end if;
                        when RX_receive_start_bit =>
                            bitindex := 0;
                            if counter = 7 then
                                counter := 0;
                                if RxD='0' then
                                    state_reg <= RX_data_receive;
                                else
                                    state_reg <= RX_receive_start_bit;
                                end if;
                            else
                                counter := counter + 1;
                                state_reg <= RX_receive_start_bit;
                            end if;
                        when RX_data_receive =>
                            if counter = 15 then
                                counter := 0;
                                data_internal(bitindex) <= RxD;
                                if bitindex = 7 then
                                    bitindex := 0;
                                    state_reg <= RX_receive_stop_bit;
                                else
                                    bitindex := bitindex + 1;
                                    state_reg <= RX_data_receive;
                                end if;
                            else                            -- No problem, or latch here, with undefined 
                                counter := counter + 1;
                                state_reg <= RX_data_receive;
                            end if;
                        when RX_receive_stop_bit =>
                            bitindex := 0;
                            if counter = 15 then
                                counter := 0;
                                if RxD='1' then             -- No latch here either?
                                    write_FIFO <= '1';
                                end if;
                                state_reg <= RX_idle;
                            else
                                counter := counter + 1;
                                state_reg <= RX_receive_stop_bit;
                            end if;
                        when others=>
                            state_reg <= RX_idle;
                    end case;
                end if;
        end process;
end rtl;