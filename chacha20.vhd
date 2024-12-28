library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ChaCha20 is
    Port (
        clk        : in std_logic;
        reset      : in std_logic;
        key        : in std_logic_vector(255 downto 0); -- 256-bit key
        nonce      : in std_logic_vector(63 downto 0);  -- 64-bit nonce
        data_in    : in std_logic_vector(127 downto 0); -- 128-bit input block
        data_out   : out std_logic_vector(127 downto 0); -- 128-bit encrypted output
        valid      : out std_logic                    -- Output valid signal
    );
end ChaCha20;

architecture Behavioral of ChaCha20 is
    -- ChaCha20 state variables
    type state_array is array (0 to 15) of std_logic_vector(31 downto 0);
    signal state : state_array;
    signal working_state : state_array;
    signal round_counter : integer range 0 to 20 := 0;
    signal round_done    : std_logic := '0';

    -- Internal signals for quarter-round operations
    signal qr_out1, qr_out2, qr_out3, qr_out4 : state_array;

begin

    -- ChaCha20 State Machine
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Initialize state with constants, key, nonce, and counter
                state(0) <= x"61707865"; -- Constant "expansion"
                state(1) <= x"3320646e"; -- Constant
                state(2) <= x"79622d32"; -- Constant
                state(3) <= x"6b206574"; -- Constant
                state(4 to 11) <= key(255 downto 0); -- Key (8 words)
                state(12) <= x"00000001"; -- Counter (start at 1)
                state(13 to 14) <= nonce(63 downto 0); -- Nonce (2 words)
                state(15) <= data_in(127 downto 96); -- Data input (example block)

                round_counter <= 0;
                round_done <= '0';
                valid <= '0';
            else
                if round_counter < 20 then
                    -- Perform Quarter-Round Operations
                    -- Row Round
                    working_state(0 to 3) <= qr_out1;
                    working_state(4 to 7) <= qr_out2;
                    working_state(8 to 11) <= qr_out3;
                    working_state(12 to 15) <= qr_out4;

                    round_counter <= round_counter + 1;
                else
                    -- Final state update (add original state to working state)
                    for i in 0 to 15 loop
                        state(i) <= std_logic_vector(unsigned(state(i)) + unsigned(working_state(i)));
                    end loop;

                    round_done <= '1';
                end if;

                -- Output the encrypted data when rounds are complete
                if round_done = '1' then
                    data_out <= state(0) & state(1) & state(2) & state(3); -- Simplified for 128-bit block
                    valid <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Quarter-Round Instantiations
    qr1: entity work.QuarterRound
    port map (
        a_in  => state(0),
        b_in  => state(1),
        c_in  => state(2),
        d_in  => state(3),
        a_out => qr_out1(0),
        b_out => qr_out1(1),
        c_out => qr_out1(2),
        d_out => qr_out1(3)
    );

    qr2: entity work.QuarterRound
    port map (
        a_in  => state(4),
        b_in  => state(5),
        c_in  => state(6),
        d_in  => state(7),
        a_out => qr_out2(0),
        b_out => qr_out2(1),
        c_out => qr_out2(2),
        d_out => qr_out2(3)
    );

    qr3: entity work.QuarterRound
    port map (
        a_in  => state(8),
        b_in  => state(9),
        c_in  => state(10),
        d_in  => state(11),
        a_out => qr_out3(0),
        b_out => qr_out3(1),
        c_out => qr_out3(2),
        d_out => qr_out3(3)
    );

    qr4: entity work.QuarterRound
    port map (
        a_in  => state(12),
        b_in  => state(13),
        c_in  => state(14),
        d_in  => state(15),
        a_out => qr_out4(0),
        b_out => qr_out4(1),
        c_out => qr_out4(2),
        d_out => qr_out4(3)
    );


end Behavioral;
