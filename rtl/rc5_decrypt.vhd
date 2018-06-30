--
-- Written by Michael Mattioli
--
--
-- Description: RC5 decryption module.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.rc5.ALL;

entity rc5_decrypt is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            ciphertext  : in std_logic_vector(63 downto 0);
            key_array   : in S; -- Key array, S.
            plaintext   : out std_logic_vector(63 downto 0));
end rc5_decrypt;
