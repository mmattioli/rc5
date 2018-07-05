--
-- Written by Michael Mattioli
--
-- Description: Key expansion module.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.rc5.all;

entity rc5_key_expansion is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            key         : in K; -- Secret key, K.
            key_array   : out S); -- Key array, S.
end rc5_key_expansion;

architecture behavioral of rc5_key_expansion is

    type state is (idle, initialize_l, initialize_s, mix_key, done);

    -- Intermediate signals are required to perform the operations; instead of declaring separate
    -- signals, define an array and use the indices as such:
    --      '0' will be considered the actual value of the register once the operation is fully
    --      completed.
    --      '1' and '2' will be considered intermediate values used to hold data while the
    --      operation is performed.
    type reg is array (0 to 2) of W;

    signal current_state : state := idle;

    signal array_l : L;
    signal array_s : S;

    signal count_i : integer;
    signal count_j : integer;
    signal count_mix : integer;

    constant magic : S := ( x"b7e15163", x"5618cb1c", x"f45044d5", x"9287be8e", x"30bf3847",
                            x"cef6b200", x"6d2e2bb9", x"0b65a572", x"a99d1f2b", x"47d498e4",
                            x"e60c129d", x"84438c56", x"227b060f", x"c0b27fc8", x"5ee9f981",
                            x"fd21733a", x"9b58ecf3", x"399066ac", x"d7c7e065", x"75ff5a1e",
                            x"1436d3d7", x"b26e4d90", x"50a5c749", x"eedd4102", x"8d14babb",
                            x"2b4c3474");

    signal a : reg;
    signal b : reg;
    signal ab : W; -- Used to hold the value of A + B.

begin

    -- A = S[i] = (S[i] + A + B) <<< 3
    a(1) <= array_s(count_i) + a(0) + b(0); -- S[i] + A + B
    a(2) <= a(1)(28 downto 0) & a(1)(31 downto 29); -- <<< 3

    -- B = L[j] = (L[j] + A + B) <<< (A + B)
    ab <= a(2) + b(0); -- A + B
    b(1) <= array_l(count_j) + ab; -- L[j] + A + B
    with ab(4 downto 0) select -- <<< (A + B)
        b(2) <= b(1)(30 downto 0) & b(1)(31) when "00001",
                b(1)(29 downto 0) & b(1)(31 downto 30) when "00010",
                b(1)(28 downto 0) & b(1)(31 downto 29) when "00011",
                b(1)(27 downto 0) & b(1)(31 downto 28) when "00100",
                b(1)(26 downto 0) & b(1)(31 downto 27) when "00101",
                b(1)(25 downto 0) & b(1)(31 downto 26) when "00110",
                b(1)(24 downto 0) & b(1)(31 downto 25) when "00111",
                b(1)(23 downto 0) & b(1)(31 downto 24) when "01000",
                b(1)(22 downto 0) & b(1)(31 downto 23) when "01001",
                b(1)(21 downto 0) & b(1)(31 downto 22) when "01010",
                b(1)(20 downto 0) & b(1)(31 downto 21) when "01011",
                b(1)(19 downto 0) & b(1)(31 downto 20) when "01100",
                b(1)(18 downto 0) & b(1)(31 downto 19) when "01101",
                b(1)(17 downto 0) & b(1)(31 downto 18) when "01110",
                b(1)(16 downto 0) & b(1)(31 downto 17) when "01111",
                b(1)(15 downto 0) & b(1)(31 downto 16) when "10000",
                b(1)(14 downto 0) & b(1)(31 downto 15) when "10001",
                b(1)(13 downto 0) & b(1)(31 downto 14) when "10010",
                b(1)(12 downto 0) & b(1)(31 downto 13) when "10011",
                b(1)(11 downto 0) & b(1)(31 downto 12) when "10100",
                b(1)(10 downto 0) & b(1)(31 downto 11) when "10101",
                b(1)(9 downto 0) & b(1)(31 downto 10) when "10110",
                b(1)(8 downto 0) & b(1)(31 downto 9) when "10111",
                b(1)(7 downto 0) & b(1)(31 downto 8) when "11000",
                b(1)(6 downto 0) & b(1)(31 downto 7) when "11001",
                b(1)(5 downto 0) & b(1)(31 downto 6) when "11010",
                b(1)(4 downto 0) & b(1)(31 downto 5) when "11011",
                b(1)(3 downto 0) & b(1)(31 downto 4) when "11100",
                b(1)(2 downto 0) & b(1)(31 downto 3) when "11101",
                b(1)(1 downto 0) & b(1)(31 downto 2) when "11110",
                b(1)(0) & b(1)(31 downto 1) when "11111",
                b(1) when others;

    state_machine : process (all)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= idle;
            else
                case current_state is
                    when idle =>
                        current_state <= initialize_l;
                    when initialize_l =>
                        if array_l(0) = key(31 downto 0) and
                            array_l(1) = key(63 downto 32) and
                            array_l(2) = key(95 downto 64) and
                            array_l(3) = key(127 downto 96) then
                            current_state <= initialize_s;
                        end if;
                    when initialize_s =>
                        if array_s = magic then
                            current_state <= mix_key;
                        end if;
                    when mix_key =>
                        if count_mix = 78 then -- Reached 78 which is 3 * max(t, c) = 3 * 26.
                            current_state <= done;
                        end if;
                    when done =>
                        -- Do nothing.
                end case;
            end if;
        end if;
    end process state_machine;

    l_data : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when initialize_l =>
                    array_l(0) <= key(31 downto 0);
                    array_l(1) <= key(63 downto 32);
                    array_l(2) <= key(95 downto 64);
                    array_l(3) <= key(127 downto 96);
                when mix_key =>
                    array_l(count_j) <= b(2);
                when others =>
                    for i in 0 to array_l'length-1 loop
                        array_l(i) <= (others => '0');
                    end loop;
            end case;
        end if;
    end process l_data;

    s_data : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when initialize_s =>
                    array_s <= magic;
                when mix_key =>
                    array_s(count_i) <= a(2);
                when others =>
            end case;
        end if;
    end process s_data;

    -- i = (i + 1)mod(t) = (i + 1)mod(26)
    counter_i : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when mix_key =>
                    if count_i = 25 then -- Reached 26.
                        count_i <= 0;
                    else
                        count_i <= count_i + 1;
                    end if;
                when others =>
                    count_i <= 0;
            end case;
        end if;
    end process counter_i;

    -- j = (j + 1)mod(c) = (j + 1)mod(4)
    counter_j : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when mix_key =>
                    if count_j = 3 then  -- Reached 4.
                        count_j <= 0;
                    else
                        count_j <= count_j + 1;
                    end if;
                when others =>
                    count_j <= 0;
            end case;
        end if;
    end process counter_j;

    counter_mix : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when mix_key =>
                    if count_mix /= 78 then -- Reached 78.
                        count_mix <= count_mix + 1;
                    end if;
                when others =>
                    count_mix <= 1;
            end case;
        end if;
    end process counter_mix;

    register_a : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when mix_key =>
                    a(0) <= a(2);
                when others =>
                    a(0) <= (others => '0');
            end case;
        end if;
    end process register_a;

    register_b : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when mix_key =>
                    b(0) <= b(2);
                when others =>
                    b(0) <= (others => '0');
            end case;
        end if;
    end process register_b;

    output : process (all)
    begin
        if rising_edge(clk) then
            case current_state is
                when done =>
                    key_array <= array_s;
                when others =>
                   for i in 0 to key_array'length-1 loop
                      key_array(i) <= (others => '0');
                   end loop;
            end case;
        end if;
    end process output;

end behavioral;
