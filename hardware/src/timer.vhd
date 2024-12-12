library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer is
    generic(period: integer);
    port(
        clk:   in std_logic;
        start: in std_logic;
        int:   out std_logic);
end Timer;

architecture Behavioral of TImer is
    signal counter: integer := 0;
    signal busy:    std_logic := '0';
begin

    process(clk) is
    begin
        if(rising_edge(clk)) then
            if(start = '1') then
                busy <= '1';
                int <= '0';
                counter <= 0;
            elsif(counter = period - 1) then
                counter <= 0;
                int <= '1';
                busy <= '0';
            elsif(busy = '1') then
                int <= '0';
                counter <= counter + 1;
            else
                busy <= '0';
                int <= '0';
                counter <= 0;
            end if;
        end if;
    end process;

end Behavioral;