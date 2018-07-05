--
-- Written by Michael Mattioli
--
-- Description: RC5 encryption module.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.rc5.all;

entity rc5_encrypt is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            plaintext   : in std_logic_vector(63 downto 0);
            key_array   : in S; -- Key array, S.
            ciphertext  : out std_logic_vector(63 downto 0));
end rc5_encrypt;

architecture behavioral of rc5_encrypt is

    type state is (idle, half_round, round, done);

    -- Intermediate signals are required to perform the operations; instead of declaring separate
    -- signals, define an array and use the indices as such:
    --      '0' will be considered the actual value of the register once the operation is fully
    --      completed.
    --      '1' will hold one of the two words which the incoming data has been split into.
    --      '2' will hold the resulting value of the half-round operation.
    --      '3' will hold the resulting value after performing the shift operation.
    --      '4' will hold the resulting value after performing the XOR operation.
    type reg is array (0 to 4) of W;

    signal current_state : state := idle;

    signal count_r : integer;

    signal a : reg;
    signal b : reg;

begin

    -- A = ((A XOR B) <<< B) + S[2 * i]
    a(4) <= a(1) XOR b(1); -- A XOR B

    with b(1)(4 downto 0) select -- (A XOR B) <<< 3
        a(3) <= a(4)(30 downto 0) & a(4)(31) when "00001",
                a(4)(29 downto 0) & a(4)(31 downto 30) when "00010",
                a(4)(28 downto 0) & a(4)(31 downto 29) when "00011",
                a(4)(27 downto 0) & a(4)(31 downto 28) when "00100",
                a(4)(26 downto 0) & a(4)(31 downto 27) when "00101",
                a(4)(25 downto 0) & a(4)(31 downto 26) when "00110",
                a(4)(24 downto 0) & a(4)(31 downto 25) when "00111",
                a(4)(23 downto 0) & a(4)(31 downto 24) when "01000",
                a(4)(22 downto 0) & a(4)(31 downto 23) when "01001",
                a(4)(21 downto 0) & a(4)(31 downto 22) when "01010",
                a(4)(20 downto 0) & a(4)(31 downto 21) when "01011",
                a(4)(19 downto 0) & a(4)(31 downto 20) when "01100",
                a(4)(18 downto 0) & a(4)(31 downto 19) when "01101",
                a(4)(17 downto 0) & a(4)(31 downto 18) when "01110",
                a(4)(16 downto 0) & a(4)(31 downto 17) when "01111",
                a(4)(15 downto 0) & a(4)(31 downto 16) when "10000",
                a(4)(14 downto 0) & a(4)(31 downto 15) when "10001",
                a(4)(13 downto 0) & a(4)(31 downto 14) when "10010",
                a(4)(12 downto 0) & a(4)(31 downto 13) when "10011",
                a(4)(11 downto 0) & a(4)(31 downto 12) when "10100",
                a(4)(10 downto 0) & a(4)(31 downto 11) when "10101",
                a(4)(9 downto 0) & a(4)(31 downto 10) when "10110",
                a(4)(8 downto 0) & a(4)(31 downto 9) when "10111",
                a(4)(7 downto 0) & a(4)(31 downto 8) when "11000",
                a(4)(6 downto 0) & a(4)(31 downto 7) when "11001",
                a(4)(5 downto 0) & a(4)(31 downto 6) when "11010",
                a(4)(4 downto 0) & a(4)(31 downto 5) when "11011",
                a(4)(3 downto 0) & a(4)(31 downto 4) when "11100",
                a(4)(2 downto 0) & a(4)(31 downto 3) when "11101",
                a(4)(1 downto 0) & a(4)(31 downto 2) when "11110",
                a(4)(0) & a(4)(31 downto 1) when "11111",
                a(4) when others;

    a(2) <= plaintext(63 downto 32) + key_array(0); -- A = A + S[0]
    a(0) <= a(3) + key_array(2 * count_r); -- S[2 * i]

    -- B = ((B XOR A) <<< 3) S[2 * i + 1]
    b(4) <= b(1) XOR a(0); -- B XOR A

    with a(0)(4 downto 0) select -- (B XOR A) <<< 3
        b(3) <= b(4)(30 downto 0) & b(4)(31) when "00001",
                b(4)(29 downto 0) & b(4)(31 downto 30) when "00010",
                b(4)(28 downto 0) & b(4)(31 downto 29) when "00011",
                b(4)(27 downto 0) & b(4)(31 downto 28) when "00100",
                b(4)(26 downto 0) & b(4)(31 downto 27) when "00101",
                b(4)(25 downto 0) & b(4)(31 downto 26) when "00110",
                b(4)(24 downto 0) & b(4)(31 downto 25) when "00111",
                b(4)(23 downto 0) & b(4)(31 downto 24) when "01000",
                b(4)(22 downto 0) & b(4)(31 downto 23) when "01001",
                b(4)(21 downto 0) & b(4)(31 downto 22) when "01010",
                b(4)(20 downto 0) & b(4)(31 downto 21) when "01011",
                b(4)(19 downto 0) & b(4)(31 downto 20) when "01100",
                b(4)(18 downto 0) & b(4)(31 downto 19) when "01101",
                b(4)(17 downto 0) & b(4)(31 downto 18) when "01110",
                b(4)(16 downto 0) & b(4)(31 downto 17) when "01111",
                b(4)(15 downto 0) & b(4)(31 downto 16) when "10000",
                b(4)(14 downto 0) & b(4)(31 downto 15) when "10001",
                b(4)(13 downto 0) & b(4)(31 downto 14) when "10010",
                b(4)(12 downto 0) & b(4)(31 downto 13) when "10011",
                b(4)(11 downto 0) & b(4)(31 downto 12) when "10100",
                b(4)(10 downto 0) & b(4)(31 downto 11) when "10101",
                b(4)(9 downto 0) & b(4)(31 downto 10) when "10110",
                b(4)(8 downto 0) & b(4)(31 downto 9) when "10111",
                b(4)(7 downto 0) & b(4)(31 downto 8) when "11000",
                b(4)(6 downto 0) & b(4)(31 downto 7) when "11001",
                b(4)(5 downto 0) & b(4)(31 downto 6) when "11010",
                b(4)(4 downto 0) & b(4)(31 downto 5) when "11011",
                b(4)(3 downto 0) & b(4)(31 downto 4) when "11100",
                b(4)(2 downto 0) & b(4)(31 downto 3) when "11101",
                b(4)(1 downto 0) & b(4)(31 downto 2) when "11110",
                b(4)(0) & b(4)(31 downto 1) when "11111",
                b(4) when others;

    b(2) <= plaintext(31 downto 0) + key_array(1); -- B = B + S[1]
    b(0) <= b(3) + key_array((2 * count_r) + 1); -- S[2 * i + 1]

    state_machine : process (all)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= idle;
            else
                case current_state is
                    when idle =>
                        for i in 0 to key_array'length-1 loop
                            if key_array(i) /= x"00000000" then
                                current_state <= half_round;
                            end if;
                        end loop;
                    when half_round =>
                        current_state <= round;
                    when round =>
                        if count_r = R then
                            current_state <= done;
                        end if;
                    when done =>
                end case;
            end if;
        end if;
    end process state_machine;

    counter_r : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when round =>
                    count_r <= count_r + 1;
                when others =>
                    count_r <= 1;
            end case;
        end if;
    end process counter_r;

    register_a : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when half_round =>
                    a(1) <= a(2);
                when round =>
                    a(1) <= a(0);
                when idle =>
                    a(1) <= (others => '0');
                when others =>
            end case;
        end if;
    end process register_a;

    register_b : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when half_round =>
                    b(1) <= b(2);
                when round =>
                    b(1) <= b(0);
                when idle =>
                    b(1) <= (others => '0');
                when others =>
            end case;
        end if;
    end process register_b;

    output : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when done =>
                    ciphertext <= a(1) & b(1);
                when others =>
                    ciphertext <= (others => '0');
            end case;
        end if;
    end process output;

end behavioral;
