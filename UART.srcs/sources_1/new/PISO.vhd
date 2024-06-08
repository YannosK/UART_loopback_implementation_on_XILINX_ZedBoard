-------------------------------------------------------------------------------------------------------------------------------------
-- Parallel Input - Serial Output register
--
-- Uses the baud16_generator as clock
-- With proper signals it takes one word in parallel
-- it fits it in a UART frame of 10 bits (adds start and stop bit)
-- sends it out sequentially at 16*times the baud clock
--
-- Uses some control signals:
--  + ready (out): signals that PISO is empty and ready to be written
--  + load (in): signal to load data into PISO
--  + start (in): when set to '1' PISO takes data and starts transmission. As long as it remains '1', process continues
--  + reset (in): resets every process going on
--
-- NOTES
--  + baud_clk is the clock for the module. reset is asynchronous
--  + when start = '1' and then '0', it takes one cycle for it to make output zero
-------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PISO is
    port
    (
        baud_clk : in std_logic;
        reset    : in std_logic;
        load     : in std_logic;
        start    : in std_logic;
        ready    : out std_logic;
        p_in     : in std_logic_vector(7 downto 0);
        s_out    : out std_logic
    );
end PISO;

architecture Behavioral of PISO is

    signal step         : integer := 0;         -- counter to count if PISO is empty
    signal baud_count   : integer := 0;         -- mod 16 counter to define send moment
    signal baud_tick    : std_logic := '0';     -- mod 16 tick, that is defined by baud_count
    signal sending      : std_logic := '0';     -- signal that PISO is sending serial data at the momment
    signal ready_int    : std_logic := '0';     -- if '1' PISO sent all data and is ready to fill
    signal shift_reg    : std_logic_vector(8 downto 0) := (others => '1'); -- internal signal to manage contents of PISO
    signal data_out     : std_logic := '1';     -- internal signal to manage the outgoing data
    
    begin

        ready <= ready_int;
        s_out <= data_out;

        mod16_counter: process (reset, baud_clk) is
            begin
                if reset = '1' then
                    baud_count <= 0;
                    baud_tick <= '0';
                else
                    if rising_edge(baud_clk) and start = '1' then
                        if baud_count /= 15 then
                            baud_count <= baud_count + 1;
                            baud_tick <= '0';
                        elsif baud_count = 15 then
                            baud_count <= 0;
                            baud_tick <= '1';
                        else
                            baud_tick <= '0';
                        end if;
                    end if;
                end if;
        end process mod16_counter;


        PISO_load: process (reset, baud_clk) is
            begin
                if reset <= '1' then
                    shift_reg <= (others => '1');
                    ready_int <= '1';
                elsif rising_edge(baud_clk) and load = '1' and ready_int = '1' and sending = '0' then
                    shift_reg <= '1' & p_in;
                    ready_int <= '0';
                end if;
        end process PISO_load;

        PISO_send: process (reset, baud_clk) is
            begin
                if reset = '1' then
                    step <= 0;
                    ready_int <= '1';
                    data_out <= '1';
                    sending <= '0';
                elsif rising_edge(baud_clk) then
                    if start = '1' and sending = '0' then
                        sending = '1';
                        data_out <= '0';
                    elsif start = '1' and sending = '1' then
                        if step = 8 then
                            step <= 0;
                            ready_int <= '1';
                            data_out <= '1';
                            sending <= '0';
                        else
                            data_out <= shift_reg(step);
                            step <= step + 1;
                            ready_int <= '0';
                            sending <= '1';
                        end if;
                    else

                    end if;

                end if;



                        if start = '1' and baud_tick = '1' then
                            if sending = '0' then
                                shift_reg <= '1' & p_in;
                                ready_int <= '0';
                                data_out <= '0';
                                sending <= '1';
                            else
                                if step = 8 then
                                    step <= 0;
                                    ready_int <= '1';
                                    shift_reg <= (others => '0');
                                    data_out <= '1';
                                    sending <= '0';
                                else
                                    data_out <= shift_reg(step);
                                    step <= step + 1;
                                    ready_int <= '0';
                                    sending <= '1';
                                end if;
                            end if;
                        elsif start = '0' then
                            step <= 0;
                            ready_int <= '1';
                            shift_reg <= (others => '0');
                            data_out <= '1';
                            sending <= '0';
                        end if;
                    end if;
                end if;
        end process PISO_send;

end Behavioral;
