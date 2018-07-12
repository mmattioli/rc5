--
-- Written by Michael Mattioli
--
-- Description: RC5 encryption module.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.rc5.all;

entity rc5_encrypt is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            plaintext   : in std_logic_vector((W'length * 2)-1 downto 0);
            key_array   : in S; -- Key array, S.
            ciphertext  : out std_logic_vector((W'length * 2)-1 downto 0));
end rc5_encrypt;

architecture behavioral of rc5_encrypt is

    type state is (idle, half_round, round, done);

    signal current_state : state := idle;

    signal count_r : integer range 1 to R;

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

    counter_r : process (clk)
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

    data : process (clk)
        variable temp_a : W;
        variable temp_b : W;
    begin
        if rising_edge(clk) then
            case current_state is
                when idle =>
                    a <= plaintext((W'length * 2)-1 downto W'length);
                    b <= plaintext(W'length-1 downto 0);
                when half_round =>
                    a <= a + key_array(0);
                    b <= b + key_array(1);
                when round =>

                    -- A = ((A XOR B) <<< B) + S[2 * i]
                    temp_a := a XOR b; -- A XOR B
                    temp_a := to_stdlogicvector(to_bitvector(temp_a) rol to_integer(unsigned(b(4 downto 0)))); -- <<< B
                    temp_a := temp_a + key_array(2 * count_r); -- + S[2 * i]
                    a <= temp_a;

                    -- B = ((B XOR A) <<< A) + S[2 * i + 1]
                    temp_b := b XOR temp_a; -- B XOR A
                    temp_b := to_stdlogicvector(to_bitvector(temp_b) rol to_integer(unsigned(temp_a(4 downto 0)))); -- <<< A
                    temp_b := temp_b + key_array(2 * count_r + 1); -- + S[2 * i + 1]
                    b <= temp_b;

                when others =>
            end case;
        end if;
    end process data;

    output : process (clk)
    begin
        if rising_edge(clk) then
            case current_state is
                when done =>
                    ciphertext <= a & b;
                when others =>
                    ciphertext <= (others => '0');
            end case;
        end if;
    end process output;

end behavioral;
