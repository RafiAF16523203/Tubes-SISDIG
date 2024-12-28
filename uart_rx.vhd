library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    port (
        clk       : in std_logic;              
        rst       : in std_logic;              
        rx        : in std_logic;             
        rx_ready  : out std_logic;           
        rx_data   : out std_logic_vector(7 downto 0) 
    );
end uart_rx;

architecture Behavioral of uart_rx is
    constant BAUD_DIV : integer := 16_000_000 / 31250; 
    signal clk_count  : integer := 0;
    signal bit_index  : integer := 0;
    signal rx_shift   : std_logic_vector(9 downto 0) := (others => '1');
    signal ready      : std_logic := '0';
begin
    process (clk, rst)
    begin
        if rst = '1' then
            clk_count <= 0;
            bit_index <= 0;
            rx_shift <= (others => '1');
            ready <= '0';
        elsif rising_edge(clk) then
            if rx = '0' and bit_index = 0 then
                -- Start bit detected
                clk_count <= 0;
                bit_index <= 1;
            elsif bit_index > 0 then
                if clk_count < BAUD_DIV then
                    clk_count <= clk_count + 1;
                else
                    clk_count <= 0;
                    rx_shift(bit_index) <= rx;
                    bit_index <= bit_index + 1;

                    if bit_index = 9 then
                        -- Stop bit received
                        rx_data <= rx_shift(8 downto 1);
                        ready <= '1';
                        bit_index <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process;

    rx_ready <= ready;
end Behavioral;
