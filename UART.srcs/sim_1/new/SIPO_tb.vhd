library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
USE std.env.all;

entity SIPO_tb is
end SIPO_tb;

architecture Behavioral of SIPO_tb is

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

    signal baud_clk : std_logic := 'X';
    signal reset    : std_logic := '1';
    signal start    : std_logic := '0';
    signal ready    : std_logic; 
    signal s_in     : std_logic := '1';
    signal p_out    : std_logic_vector(7 downto 0);

    signal data     : std_logic_vector(9 downto 0) := "1101010101"; -- NO START BIT INCLUDED, stop bits included intentionally

    constant baud_period : time := 500 ns;

    begin

        uut: SIPO port map
            (
                baud_clk => baud_clk, 
                reset    => reset   , 
                start    => start   , 
                ready    => ready   , 
                s_in     => s_in    , 
                p_out    => p_out
            );

        baud16_gen: process is
            begin
		        baud_clk <= '1';
		        wait for 10 ns;
		        baud_clk <= '0';
		        wait for baud_period - 10 ns;
        end process baud16_gen;

        testbench: process is
            begin
                
                reset <= '1';
                wait for 2*baud_period;
                wait until falling_edge(baud_clk);
                reset <= '0';
                wait for 2*baud_period;

                -- simulating the start bit
                s_in <= '0';
                wait for (16*baud_period)/2;
                -- FSM signals start
                start <= '1';
                wait for (16*baud_period)/2;

                for I in 0 to 9 loop
                    s_in <= data(I);
                    wait for baud_period*16;
                end loop;
                wait for baud_period;
                
                -- checking if start does a resetI
                start <= '0';
                wait for 2*baud_period;

                stop(2);

        end process testbench;

end Behavioral;
