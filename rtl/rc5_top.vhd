--
-- Written by Michael Mattioli
--
--
-- Description: Top-level module of RC5 module.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rc5 is
    port (  clr         : in std_logic;
            clk         : in std_logic;
            enc         : in std_logic; -- High = encrypt, low = decrypt.
            key         : in std_logic; -- Input is user key.
            data        : in std_logic; -- Input is user data.
            data_in     : in std_logic_vector(63 downto 0);
            data_out    : out std_logic_vector(63 downto 0));
end rc5;
