library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE std.env.all;

entity PISO_tb is
end PISO_tb;

architecture Behavioral of PISO_tb is

    component PISO is
        port
        (
            baud_clk : in std_logic;
            reset    : in std_logic;
            start    : in std_logic;
            ready    : out std_logic;
            p_in     : in std_logic_vector(7 downto 0);
            s_out    : out std_logic
        );
    end component PISO;
    
    signal baud_clk : std_logic;
    signal reset    : std_logic := '1';
    signal start    : std_logic := '0';
    signal ready    : std_logic;
    signal p_in     : std_logic_vector(7 downto 0) := (others => 'X');
    signal s_out    : std_logic;
    
    signal data     : std_logic_vector(7 downto 0) := "01010101"; -- NO START BIT INCLUDED, stop bits included intentionally

    constant baud16_period : time := 550 ns;
    constant baud_period   : time := 8800 ns;

    begin

        uut: PISO port map
            (
                baud_clk => baud_clk,
                reset    => reset,
                start    => start,
                ready    => ready,
                p_in     => p_in,
                s_out    => s_out               
            );

        baud16_gen: process is
            begin
		        baud_clk <= '1';
		        wait for 10 ns;
		        baud_clk <= '0';
		        wait for baud16_period - 10 ns;
        end process baud16_gen;

        testbench: process is
            begin
                
                reset <= '1';
                wait for 2*baud16_period;
                wait until falling_edge(baud_clk);
                reset <= '0';
                wait for 2*baud16_period;

                -- simulating incoming data
                p_in <= data;
                assert ready = '1' report "After reset and as long as start = '0' PISO should be ready, but it's not";
                wait for baud_period;
                wait until falling_edge(baud_clk);

                -- start of transmission
                start <= '1';

                wait for 12*baud_period;
                stop(1);
                
                wait until falling_edge(baud_clk);
                
                -- checking if start does a resetI
                start <= '0';
                wait for 2*baud_period;

                stop(2);

        end process testbench;

end Behavioral;
