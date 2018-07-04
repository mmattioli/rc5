--
-- Written by Michael Mattioli
--
-- Description: Key expansion module.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package rc5 is

    subtype W is std_logic_vector(31 downto 0); -- 32-bit word, 64-bit plaintext and ciphertext.
    subtype K is std_logic_vector(127 downto 0); -- 128-bit secret key.
    constant R : std_logic_vector(3 downto 0) := "1100"; -- 12 rounds.
    type S is array (0 to 25) of W; -- Table of 26 words; 2(rounds + 1).
    type L is array (0 to 3) of W; -- Table of 4 words; (secret key bytes / (word / 8)).

end rc5;
