library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_top_tb is
end entity uart_top_tb;

architecture Behavioral of uart_top_tb is
    -- Constants for simulation
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz clock
    
    -- Signals for DUT (Device Under Test)
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal rx        : std_logic := '1'; -- UART RX input (idle high)
    signal tx        : std_logic;        -- UART TX output
    signal key       : std_logic_vector(255 downto 0); -- ChaCha20 key
    signal nonce     : std_logic_vector(63 downto 0);  -- ChaCha20 nonce
    
    -- Testbench signals
    signal tx_data   : std_logic_vector(7 downto 0);   -- Test data to send
    signal rx_ready  : std_logic := '0';              -- Ready to send new byte
    signal rx_busy   : std_logic := '0';              -- Simulate UART RX busy
    signal encrypted_data : std_logic_vector(7 downto 0); -- Encrypted data received
    signal valid_out      : std_logic := '0';          -- Valid signal for received data

begin
    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- DUT Instance
    uart_top_inst : entity work.uart_top
        port map (
            clk     => clk,
            rst     => rst,
            rx      => rx,
            tx      => tx,
            key     => key,
            nonce   => nonce
        );

    -- Stimulus process
    stimulus_process : process
    begin
        -- Reset the system
        rst <= '1';
        wait for 100 ns;
        rst <= '0';

        -- Provide ChaCha20 key and nonce
        key   <= x"000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F";
        nonce <= x"0001020304050607";

        -- Simulate UART RX input (sending data to DUT)
        send_uart_byte(x"90"); -- MIDI Note On command
        send_uart_byte(x"3C"); -- MIDI Note (Middle C)
        send_uart_byte(x"7F"); -- Velocity (127)

        -- Wait for encryption to finish and observe TX output
        wait for 1 us;
        assert valid_out = '1' report "Encrypted data not valid!" severity error;

        -- Check that the encrypted output is correct
        -- (This requires precomputed expected values)
        wait;

    end process;

    -- UART Transmission Task
    procedure send_uart_byte(signal byte : in std_logic_vector(7 downto 0)) is
    begin
        -- Start bit
        rx <= '0';
        wait for CLK_PERIOD * 10; -- UART start bit duration

        -- Transmit each data bit (LSB first)
        for i in 0 to 7 loop
            rx <= byte(i);
            wait for CLK_PERIOD * 10; -- UART bit duration
        end loop;

        -- Stop bit
        rx <= '1';
        wait for CLK_PERIOD * 10; -- UART stop bit duration
    end procedure;

end Behavioral;
