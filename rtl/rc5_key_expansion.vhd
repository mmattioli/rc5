--
-- Written by Michael Mattioli
--
--
-- Description: Key expansion module.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.rc5.ALL;

entity rc5_key_expansion is
    port (  clk         : in std_logic;
            rst         : in std_logic;
            key         : in K; -- Secret key, K.
            key_array   : out S); -- Key array, S.
end rc5_key_expansion;
