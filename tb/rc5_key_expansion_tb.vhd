--
-- Written by Michael Mattioli
--
-- Description: Testbench for RC5 key expansion module.
--

library std;
library ieee;
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.rc5.all;

entity rc5_key_expansion_tb is
end rc5_key_expansion_tb;

architecture behavioral of rc5_key_expansion_tb is

    component rc5_key_expansion
        port (  clk         : in std_logic;
                rst         : in std_logic;
                key         : in K; -- Secret key, K.
                key_array   : out S); -- Key array, S.
    end component;

    constant clk_period : time := 10ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal key : K;
    signal key_array : S;

begin

    -- Instantiate the unit under test.
    uut : rc5_key_expansion port map (  clk => clk,
                                        rst => rst,
                                        key => key,
                                        key_array => key_array);

    -- Apply the clock.
    applied_clk : process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process applied_clk;

    -- Apply the stimuli to the unit under test.
    stimuli : process
    begin
        key <= x"12082249120822491208224912082249";
        wait for clk_period * ((3 * key_array'length) + 3 + key_array'length);
        assert (key_array = (   x"9bbbd8c8", x"1a37f7fb", x"46F8E8C5", x"460C6085", x"70F83B8A",
                                x"284B8303", x"513E1454", x"F621ED22", x"3125065D", x"11A83A5D",
                                x"D427686B", x"713AD82D", x"4B792F99", x"2799A4DD", x"A7901C49",
                                x"DEDE871A", x"36C03196", x"A7EFC249", x"61A78BB8", x"3B0A1D2B",
    							x"4DBFCA76", x"AE162167", x"30D76B0A", x"43192304", x"F6CC1431",
                                x"65046380"));
    end process stimuli;

end behavioral;
