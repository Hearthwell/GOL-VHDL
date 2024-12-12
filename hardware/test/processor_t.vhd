library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Processor_t is
end Processor_t;

architecture Behavioral of Processor_t is
    constant PERIOD: time := 10 ns;
    signal clk: std_logic := '0';
    signal tx : STD_LOGIC;

begin

    GOLProcessor: entity work.GOLProcessor(Behavioral) generic map(8, 2, 1000) port map(clk, tx);

    process is
    begin
        clk <= not clk;
        wait for 1 ns;
    end process;

    process is
    begin
        wait for 1000 * PERIOD;
        assert 0 = 1 report "ALL TEST PASSED" severity failure;
    end process;

end Behavioral;