--
-- Written by Michael Mattioli
--
-- Description: RC5 decryption module.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.rc5.all;

entity rc5_decrypt is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            ciphertext  : in std_logic_vector((W'length * 2)-1 downto 0);
            key_array   : in S; -- Key array, S.
            plaintext   : out std_logic_vector((W'length * 2)-1 downto 0));
end rc5_decrypt;

architecture behavioral of rc5_decrypt is

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
                                current_state <= round;
                            end if;
                        end loop;
                    when round =>
                        if count_r = 1 then
                            current_state <= half_round;
                        end if;
                    when half_round =>
                        current_state <= done;
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
                    count_r <= count_r - 1;
                when others =>
                    count_r <= 12;
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
                    a <= ciphertext((W'length * 2)-1 downto W'length);
                    b <= ciphertext(W'length-1 downto 0);
                when round =>

                    -- B = ((B - S[2 * i + 1]) >>> A) XOR A;
                    temp_b := b - key_array(2 * count_r + 1); -- (B - S[2 * i + 1])
                    temp_b := to_stdlogicvector(to_bitvector(temp_b) ror to_integer(unsigned(a(4 downto 0)))); -- >>> A
                    temp_b := temp_b XOR a; -- XOR A
                    b <= temp_b;

                    -- A = ((A - S[2 * i]) >>> B) XOR B;
                    temp_a := a - key_array(2 * count_r); -- (A - S[2 * i])
                    temp_a := to_stdlogicvector(to_bitvector(temp_a) ror to_integer(unsigned(temp_b(4 downto 0)))); -- >>> B
                    temp_a := temp_a XOR temp_b; -- XOR B
                    a <= temp_a;

                when half_round =>
                    b <= b - key_array(1);
                    a <= a - key_array(0);
                when others =>
            end case;
        end if;
    end process data;

    output : process (clk)
    begin
        if rising_edge(clk) then
            case current_state is
                when done =>
                    plaintext <= a & b;
                when others =>
                    plaintext <= (others => '0');
            end case;
        end if;
    end process output;

end behavioral;
