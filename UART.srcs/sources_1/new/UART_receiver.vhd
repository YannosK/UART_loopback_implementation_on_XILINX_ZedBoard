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
        RX_check_stop,
        RX_FIFO_write
    );

    signal current_state    : FSM_states;
    signal next_state       : FSM_states;

    begin

        RX_FIFO: fifo_generator_0 port map
                (
                    clk   => clock,
                    srst  => reset,
                    din   => ,
                    wr_en => ,
                    rd_en => ,
                    dout  => Rx_Data,
                    full  => ,
                    empty => 
                );

        RX_SIPO: SIPO port map
                (
                    baud_clk => baud_ref,
                    reset    => reset,
                    start    => ,
                    ready    => ,
                    s_in     => RxD,
                    p_out    => 
                );

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
                    when RX_idle        =>
                    when RX_start_check =>
                    when RX_data_fetch  =>
                    when RX_check_stop  =>
                    when RX_FIFO_write  =>
                    when others =>
                        next_state <= TX_idle;
                end case;
        end process state_logic;

end Behavioral;
