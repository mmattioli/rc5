--
-- Written by Michael Mattioli
--
-- Description: RC5 key expansion module.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.rc5.all;

entity rc5_key_expansion is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            key         : in K; -- Secret key, K.
            key_array   : out S); -- Key array, S.
end rc5_key_expansion;

architecture behavioral of rc5_key_expansion is

    type state is (idle, initialize, mix_key, done);

    signal current_state : state := idle;

    signal array_l : L;
    signal array_s : S;

    signal count_i : integer range 0 to T-1;
    signal count_j : integer range 0 to C-1;
    signal count_mix : integer range 1 to (3 * T);

    constant magic : S := ( x"b7e15163", x"5618cb1c", x"f45044d5", x"9287be8e", x"30bf3847",
                            x"cef6b200", x"6d2e2bb9", x"0b65a572", x"a99d1f2b", x"47d498e4",
                            x"e60c129d", x"84438c56", x"227b060f", x"c0b27fc8", x"5ee9f981",
                            x"fd21733a", x"9b58ecf3", x"399066ac", x"d7c7e065", x"75ff5a1e",
                            x"1436d3d7", x"b26e4d90", x"50a5c749", x"eedd4102", x"8d14babb",
                            x"2b4c3474");

    signal a : W;
    signal b : W;

begin

    state_machine : process (clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= idle;
            else
                case current_state is
                    when idle =>
                        current_state <= initialize;
                    when initialize =>
                        current_state <= mix_key;
                    when mix_key =>
                        if count_mix = (3 * T) then -- Reached 78 which is 3 * max(t, c) = 3 * 26.
                            current_state <= done;
                        end if;
                    when done =>
                end case;
            end if;
        end if;
    end process state_machine;

    data : process (clk)
        variable temp_a : W;
        variable temp_b : W;
        variable temp_ab : W;
    begin
        if rising_edge(clk) then
            case current_state is
                when idle =>
                    for i in 0 to array_l'length-1 loop
                        array_l(i) <= (others => '0');
                    end loop;
                when initialize =>

                    -- Fill array L with secret key K.
                    for i in 0 to array_l'length-1 loop
                        array_l(i) <= key((W'length * (i + 1))-1 downto W'length * i);
                    end loop;

                    -- Fill array S with magic constants.
                    array_s <= magic;

                    -- Zero A and B.
                    a <= (others => '0');
                    b <= (others => '0');

                when mix_key =>

                    -- A = S[i] = (S[i] + A + B) <<< 3
                    temp_a := array_s(count_i) + a + b; -- S[i] + A + B
                    temp_a := to_stdlogicvector(to_bitvector(temp_a) rol 3); -- <<< 3
                    a <= temp_a; -- Update A
                    array_s(count_i) <= temp_a; -- Update S[i]

                    -- B = L[j] = (L[j] + A + B) <<< (A + B)
                    temp_b := array_l(count_j) + temp_a + b; -- (L[j] + A + B)
                    temp_ab := temp_a + b;
                    temp_b := to_stdlogicvector(to_bitvector(temp_b) rol to_integer(unsigned(temp_ab(4 downto 0)))); -- <<< (A + B)
                    b <= temp_b; -- Update B
                    array_l(count_j) <= temp_b; -- Update L[j]

                when others =>
            end case;
        end if;
    end process data;

    -- i = (i + 1)mod(t) = (i + 1)mod(26)
    counter_i : process (clk)
    begin
        if rising_edge(clk) then
            case current_state is
                when mix_key =>
                    if count_i = (T - 1) then
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
    counter_j : process (clk)
    begin
        if rising_edge(clk) then
            case current_state is
                when mix_key =>
                    if count_j = (C - 1) then
                        count_j <= 0;
                    else
                        count_j <= count_j + 1;
                    end if;
                when others =>
                    count_j <= 0;
            end case;
        end if;
    end process counter_j;

    counter_mix : process (clk)
    begin
        if rising_edge(clk) then
            case current_state is
                when mix_key =>
                    count_mix <= count_mix + 1;
                when others =>
                    count_mix <= 1;
            end case;
        end if;
    end process counter_mix;

    output : process (clk)
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
