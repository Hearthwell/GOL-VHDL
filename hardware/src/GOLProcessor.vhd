library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- FOR NOW SIZE MUST BE A MULTIPLE OF 8 BITS SO WE CAN SEND IT THROUGHT THE UART WITHOUT PROBLEMS
entity GOLProcessor is
    generic(SIZE        : integer := 32;
            BAUDRATE    : integer;
            TIMER_PERIOD: INTEGER);
    port(clk: in std_logic;
         tx : out std_logic);
end GOLProcessor;

architecture Behavioral of GOLProcessor is
    type GOL_Memory is array (0 to SIZE + 1) of std_logic_vector(0 to SIZE + 1);
    signal world: GOL_Memory := (3 => "0000100000",
                                 4 => "0001100000",   
                                 5 => "0000110000",   
                                 others => (others => '0'));
    signal next_world: GOL_Memory;

    type GOL_Neighbours is array(0 to SIZE * SIZE - 1) of std_logic_vector(7 downto 0);
    signal neighbours: GOL_Neighbours;
    signal world_transfer: STD_LOGIC;

    signal compute : std_logic;
    signal tx_ready: std_logic;
    signal tx_data : std_logic_vector(7 downto 0);
    signal tx_busy : std_logic;
    signal tx_s    : std_logic;

    signal timer_start : STD_LOGIC;
    signal timer_ready : STD_LOGIC;

    signal idx_y: integer;
    signal idx_x: integer;
    signal map_done : STD_LOGIC;

    signal reset: STD_LOGIC := '1';

begin
    uart: entity work.Uart(RTL) generic map(baudrate) port map(clk, tx_ready, tx_data, tx_busy, tx_s);
    timer: entity work.Timer(Behavioral) generic map(TIMER_PERIOD) port map(clk, timer_start, timer_ready);
    next_world(0) <= (OTHERS => '0');
    next_world(SIZE + 1) <= (OTHERS => '0');
    g1: for i in 1 to SIZE generate
        next_world(i)(0) <= '0';
        next_world(i)(SIZE + 1) <= '0';
        g2: for j in 1 to SIZE generate
                neighbours((i - 1) * SIZE + (j - 1)) <= world(i - 1)(j - 1) & world(i - 1)(j) & world(i - 1)(j + 1) & world(i)(j - 1) & world(i)(j + 1) & world(i + 1)(j - 1) & world(i + 1)(j) & world(i + 1)(j + 1);
                GOLCore_ij: entity work.GOLCore(Behavioral) port map(clk => clk, ready => compute, neighbours => neighbours((i - 1) * SIZE + (j - 1)), previous_s => world(i)(j), next_s => next_world(i)(j));
            end generate;
        end generate;
        
    process(clk) is
    begin
        if(rising_edge(clk)) then

            if(reset = '1' or (timer_ready = '1' and map_done = '1')) then
                compute <= '1';
                timer_start <= '1';
                tx_ready <= '0';
                idx_y <= 0;
                idx_x <= 0;
                map_done <= '0';
                reset <= '0';
                world_transfer <= '0';
            
            elsif(compute = '1') then
                compute <= '0';
                idx_y <= 1;
                idx_x <= 1;
                map_done <= '0';
                timer_start <= '0';
                world_transfer <= '1';

            elsif(map_done = '0') then

                if(world_transfer = '1') then
                    world_transfer <= '0';
                    world(1 to SIZE)(1 to SIZE) <= next_world(1 to SIZE)(1 to SIZE);
                elsif(tx_busy = '0' and tx_ready = '0') then
                    if(idx_y = SIZE + 1) then
                        map_done <= '1';
                    elsif(idx_x = SIZE + 1) then
                        idx_x <= 1;
                        idx_y <= idx_y + 1;
                    else
                        idx_x <= idx_x + 8;
                        tx_data <= world(idx_y)(idx_x to idx_x + 7);
                        tx_ready <= '1';
                    end if;
                else
                    tx_ready <= '0';
                    tx_data <= (others => '0');
                end if;

            end if;
            
        end if;
    end process;

    tx <= tx_s;

end Behavioral;