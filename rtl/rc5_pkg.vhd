--
-- Written by Michael Mattioli
--
-- Description: RC5 package.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package rc5 is

    subtype W is std_logic_vector(31 downto 0); -- 32-bit word, 64-bit plaintext and ciphertext.
    subtype K is std_logic_vector(127 downto 0); -- 128-bit secret key.
    constant R : integer := 12; -- 12 rounds.
    constant T : integer := 2 * (R + 1); -- Size of array S.
    constant C : integer := (K'length / 8) / (W'length / 8); -- Size of array L.
    type S is array (0 to T-1) of W; -- Table of 26 words; 2(rounds + 1).
    type L is array (0 to C-1) of W; -- Table of 4 words; (secret key bytes / (word / 8)).

end rc5;
