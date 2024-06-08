library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder_accum_4bit is
    port
    (
        clk     : in std_logic;
        reset   : in std_logic;
        add     : in std_logic;
        d_out   : out std_logic_vector (3 downto 0)
    );
end adder_accum_4bit;

architecture Behavioral of adder_accum_4bit is

    signal data_i : integer := 0;

    begin

        d_out <= std_logic_vector(to_unsigned(data_i, d_out'length));

        process (clk, reset) is
            begin
                if reset = '1' then
                    data_i <= 0;
                elsif rising_edge(clk) then
                    if (add = '1') then
                        if data_i = 8 then
                            data_i <= 0;
                        else
                            data_i <= data_i + 1;
                        end if;
                    end if;
                end if;
        end process;
end Behavioral;