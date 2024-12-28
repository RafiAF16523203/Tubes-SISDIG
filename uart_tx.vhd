library ieee;
use ieee.std_logic_1164.all;
use ieee.numberic_std.all;


entity uart_tx is
    port (
        clk      : in std_logic;              -- System clock
        rst      : in std_logic;              -- Reset
        tx_start : in std_logic;              -- Start transmission
        tx_data  : in std_logic_vector(7 downto 0); -- Byte to send
        tx_busy  : out std_logic;             -- UART busy status
        tx       : out std_logic              -- UART TX line
    );
end uart_tx;

architecture Behavioral of uart_tx is
    constant BAUD_DIV : integer := 16_000_000 / 31250; -- Clock cycles per bit
    signal clk_count  : integer := 0;
    signal bit_index  : integer := 0;
    signal tx_shift   : std_logic_vector(9 downto 0) := (others => '1'); -- Start/stop bits
    signal busy       : std_logic := '0';
begin
    process (clk, rst)
    begin
        if rst = '1' then
            tx <= '1';
            busy <= '0';
            clk_count <= 0;
            bit_index <= 0;
            tx_shift <= (others => '1');
        elsif rising_edge(clk) then
            if tx_start = '1' and busy = '0' then
                -- Start transmission
                tx_shift <= '0' & tx_data & '1'; -- Start bit, data, stop bit
                busy <= '1';
                bit_index <= 0;
                clk_count <= 0;
            elsif busy = '1' then
                if clk_count < BAUD_DIV then
                    clk_count <= clk_count + 1;
                else
                    clk_count <= 0;
                    tx <= tx_shift(bit_index);
                    bit_index <= bit_index + 1;

                    if bit_index = 9 then
                        busy <= '0'; -- End of transmission
                    end if;
                end if;
            end if;
        end if;
    end process;

    tx_busy <= busy;
end Behavioral;
