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

        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        key <= x"12082249120822491208224912082249";
        wait for clk_period * ((3 * key_array'length) + 2);
        assert( key_array = (   x"78600507", x"757d940c", x"51feb1c4", x"80d57578", x"086d8132",
                                x"09f462b7", x"72ec15e4", x"1ddb087d", x"54e8c8e3", x"d83fae59",
                                x"76f69b72", x"a4541443", x"576f3690", x"7cae8ea1", x"9824499f",
                                x"080590cc", x"43a3e585", x"f6e79c2e", x"6e489e6d", x"cb4dbaee",
                                x"aacf4627", x"8d8153e9", x"114044fd", x"90388748", x"05cde530",
                                x"bfc64c58"));

        finish(0);

    end process stimuli;

end behavioral;
