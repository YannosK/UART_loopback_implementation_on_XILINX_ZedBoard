library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_8bit is
    port
    (
        clk     : in std_logic;
        reset   : in std_logic;
        we      : in std_logic;
        d_in    : in std_logic_vector (7 downto 0);
        d_out   : out std_logic_vector (7 downto 0)
    );
end reg_8bit;

architecture Behavioral of reg_8bit is
    begin
        process (clk)
        begin
            if reset = '1' then
                d_out <= (others => '1');
            elsif rising_edge(clk) then
                if (we = '1') then
                    d_out <= d_in;
                end if;
            end if;
        end process;
end Behavioral;