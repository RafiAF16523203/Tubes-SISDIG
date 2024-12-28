library ieee;                     -- Declare the IEEE library
use ieee.std_logic_1164.all;      -- Use the standard logic package
use ieee.numeric_std.all;         -- (Optional) Use numeric operations package


entity uart_top is
    port (
        clk      : in std_logic;              -- System clock
        rst      : in std_logic;              -- Reset
        tx_start : in std_logic;              -- Start signal for TX
        tx_data  : in std_logic_vector(7 downto 0); -- Data to transmit
        rx_ready : out std_logic;             -- Data ready signal from RX
        rx_data  : out std_logic_vector(7 downto 0); -- Received data
        tx       : out std_logic;             -- UART TX line
        rx       : in std_logic               -- UART RX line
    );
end uart_top;

architecture Behavioral of uart_top is
    signal tx_busy : std_logic;
begin
    -- Instantiate UART Transmitter
    uart_tx_inst: entity work.uart_tx
        port map (
            clk      => clk,
            rst      => rst,
            tx_start => tx_start,
            tx_data  => tx_data,
            tx_busy  => tx_busy,
            tx       => tx
        );

    -- Instantiate UART Receiver
    uart_rx_inst: entity work.uart_rx
        port map (
            clk      => clk,
            rst      => rst,
            rx       => rx,
            rx_ready => rx_ready,
            rx_data  => rx_data
        );

end Behavioral;
