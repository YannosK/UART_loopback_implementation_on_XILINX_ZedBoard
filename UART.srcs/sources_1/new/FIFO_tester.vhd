library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity FIFO_tester is
    port
    (
        clk     : in std_logic;
        reset   : in std_logic;
        d_in    : in std_logic_vector(7 downto 0);
        d_out   : out std_logic_vector(7 downto 0);
        we      : in std_logic;
        re      : in std_logic;
        full    : out std_logic;
        empty   : out std_logic
    );
end FIFO_tester;

architecture Behavioral of FIFO_tester is

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

    begin

        RX_FIFO: fifo_generator_0 port map
                (
                    clk   => clk,
                    srst  => reset,
                    din   => d_in,
                    wr_en => we,
                    rd_en => re,           -- you have to make sure in the other side, that FIFO is not empty, and you don't read something empty
                    dout  => d_out,
                    full  => full,
                    empty => empty
                );

end Behavioral;
