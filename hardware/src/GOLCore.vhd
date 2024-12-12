library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GOLCore is
    port(
        clk:        in std_logic;
        ready:      in std_logic;
        neighbours: in std_logic_vector(7 downto 0);
        previous_s: in std_logic;
        next_s:     out std_logic);
end GOLCore;

architecture Behavioral of GOLCore is
    constant GOL_UNDER_POPULATION_TRESH: integer := 2;
    constant GOL_OVER_POPULATION_TRESH : integer := 3;

    signal state_n : STD_LOGIC;

begin
    
    process(clk) is
        variable counter: integer := 0; 
    begin
        if(rising_edge(clk) and ready = '1') then
            counter := 0;
            for i in 0 to neighbours'length - 1 loop
                if(neighbours(i) = '1') then
                    counter := counter + 1;
                end if;
            end loop;

            if counter < GOL_UNDER_POPULATION_TRESH then
                state_n <= '0';
            elsif counter = GOL_UNDER_POPULATION_TRESH then
                state_n <= previous_s;
            elsif counter = GOL_OVER_POPULATION_TRESH then
                state_n <= '1';
            else
                state_n <= '0';
            end if;

        end if;
    end process;

    next_s <= state_n when (state_n = '0' or state_n = '1') else previous_s;

end Behavioral;