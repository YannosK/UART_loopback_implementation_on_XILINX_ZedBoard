library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE std.env.all;

entity uart_system_top_tb is
end uart_system_top_tb;

architecture Behavioral of uart_system_top_tb is

    component uart_system_top is
      port
      (
        clk_100MHz : in  std_logic;
        rst        : in  std_logic;
        RxD        : in  std_logic;
        TxD        : out std_logic
      );
    end component uart_system_top;

    signal clk_100MHz : std_logic;
    signal rst        : std_logic := '1';
    signal RxD        : std_logic := '1';
    signal TxD        : std_logic;

    signal incoming_symbol : std_logic_vector(9 downto 0) := "1010101010";

    constant baud           : integer := 115200;
    constant clk_period     : time := 10 ns;
    constant baud16_period  : time := 550 ns;
    constant baud_period    : time := 8800 ns;

    begin

        uut: uart_system_top port map
            (
                clk_100MHz => clk_100MHz,
                rst        => rst,
                RxD        => RxD,
                TxD        => TxD
            );

        clock_system: process is
            begin
                clk_100MHz <= '1';
                wait for clk_period/2;
                clk_100MHz <= '0';
                wait for clk_period/2;
        end process clock_system;

        testbench: process is
            begin
                
                rst <= '1';
                wait for 2*baud16_period;
                rst <= '0';
                wait for 2*baud16_period;

                stop(1);

                report "Incoming symbol arrives";

                for I in 0 to 9 loop
                    RxD <= incoming_symbol(I);
                    wait for baud_period;
                end loop;

                wait for 2*baud_period;

                report "Successfully received";

                stop(2);

                wait for 12*baud_period;

                report "Successfully transmitted";

                stop(3);
                
        end process testbench;

end Behavioral;
