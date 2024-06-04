library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE std.env.all;

entity baudrate_generator_tb is
end baudrate_generator_tb;

architecture Behavioral of baudrate_generator_tb is

    component baudrate_generator is
        generic (baudRate : integer := 115200);
        Port 
        (
            clock       : in std_logic;
            en_16x_baud : out std_logic;
            reset       : in std_logic
        );
    end component baudrate_generator;

    signal clock       : std_logic := 'X';
    signal en_16x_baud : std_logic := 'X';
    signal reset       : std_logic := '1';

    constant clk_period : time := 10 ns; 	-- Zeadboard 100MHz oscillator 
    constant baud       : positive := 115200;
    
    begin

        uut: baudrate_generator generic map (baudRate => baud)
                                port map
                                (
                                    clock       => clock,
                                    en_16x_baud => en_16x_baud,
                                    reset       => reset
                                );

        clock_gen: process is
            begin
		        clock <= '0';
		        wait for clk_period/2;
		        clock <= '1';
		        wait for clk_period/2;
        end process clock_gen;

        stimulus: process is
            begin
                reset <= '1';
                wait for 2*clk_period;
                wait until falling_edge(clock);
                reset <= '0';
                wait for 10*54.25*clk_period;       -- it does run for 9 cycles, not 10 !!!
                wait until falling_edge(clock);
                reset <= '1';
                wait for 2*clk_period;
                stop;
        end process stimulus;

end Behavioral;
