library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Uart is
    generic(period: integer);
    port(
        clk    :  in std_logic;
        tx_rdy :  in std_logic;
        tx_data:  in std_logic_vector(7 downto 0);
        tx_busy:  out std_logic;
        tx     :  out std_logic);
end Uart;

architecture RTL of Uart is
    constant paquet_size: integer := 8;

    signal data   : std_logic_vector(7 downto 0) := (others => '0');
    signal counter: integer   := 0;
    signal idx    : integer   := 0;
    signal running: std_logic := '0';
begin
    process(clk) is
    begin
        if(rising_edge(clk)) then
            if(tx_rdy = '1') then

                data <= tx_data;
                counter <= 0;
                idx <= 0;
                running <= '1';
                tx <= '0'; -- Starting bit for Uart

            elsif(counter = period - 1) then
                counter <= 0;

                if(idx = paquet_size) then
                    tx <= '1';
                    idx <= idx + 1;
                elsif(idx = paquet_size + 1) then
                    tx <= '1';
                    running <= '0';
                    idx <= 0;
                else
                    tx <= data(idx);
                    idx <= idx + 1;
                end if;

            elsif(running = '1') then

                counter <= counter + 1;
            
            else 
                tx <= '1';
            end if;
        end if;
    end process;

    tx_busy <= running;

end RTL;