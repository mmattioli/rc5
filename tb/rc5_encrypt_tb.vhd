--
-- Written by Michael Mattioli
--
-- Description: Testbench for RC5 encryption module.
--

library std;
library ieee;
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.rc5.all;

entity rc5_key_encrypt_tb is
end rc5_key_encrypt_tb;

architecture behavioral of rc5_key_encrypt_tb is

    component rc5_encrypt
        port (  clk         : in std_logic;
                rst         : in std_logic;
                plaintext   : in std_logic_vector((W'length * 2)-1 downto 0);
                key_array   : in S; -- Key array, S.
                ciphertext  : out std_logic_vector((W'length * 2)-1 downto 0));
    end component;

    constant clk_period : time := 10ns;

    constant s_empty : S := (   x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
                                x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
                                x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
                                x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
                                x"00000000", x"00000000", x"00000000", x"00000000", x"00000000",
                                x"00000000");

    -- Expanded key table for key 0x12082249120822491208224912082249.
    constant s_expanded : S := (x"78600507", x"757d940c", x"51feb1c4", x"80d57578", x"086d8132",
                                x"09f462b7", x"72ec15e4", x"1ddb087d", x"54e8c8e3", x"d83fae59",
                                x"76f69b72", x"a4541443", x"576f3690", x"7cae8ea1", x"9824499f",
                                x"080590cc", x"43a3e585", x"f6e79c2e", x"6e489e6d", x"cb4dbaee",
                                x"aacf4627", x"8d8153e9", x"114044fd", x"90388748", x"05cde530",
                                x"bfc64c58");

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal plaintext : std_logic_vector((W'length * 2)-1 downto 0);
    signal key_array : S;
    signal ciphertext : std_logic_vector((W'length * 2)-1 downto 0);

begin

    -- Instantiate the unit under test.
    uut : rc5_encrypt port map (clk => clk,
                                rst => rst,
                                plaintext => plaintext,
                                key_array => key_array,
                                ciphertext => ciphertext);

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
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"1208224912082249";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert (ciphertext = x"9112E77164848CEC");

        rst <= '1';
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"9112E77164848CEC";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert (ciphertext = x"9C7A45D860BE4B9D");

        rst <= '1';
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"9C7A45D860BE4B9D";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert (ciphertext = x"AEE9B73C9871E7F6");

        rst <= '1';
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"AEE9B73C9871E7F6";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert (ciphertext = x"7AF099359361975E");

        rst <= '1';
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"7AF099359361975E";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert(ciphertext = x"1949A20065B0003D");

        rst <= '1';
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"1949A20065B0003D";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert (ciphertext = x"43B8F430ADB3C292");

        rst <= '1';
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"43B8F430ADB3C292";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert (ciphertext = x"52B2097EE281088C");

        rst <= '1';
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"52B2097EE281088C";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert (ciphertext = x"EB9B8A50B1778384");

        rst <= '1';
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"EB9B8A50B1778384";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert (ciphertext = x"FD8FCE1C50A93116");

        rst <= '1';
        key_array <= s_empty;
        wait for clk_period;
        rst <= '0';
        wait for clk_period;

        plaintext <= x"FD8FCE1C50A93116";
        key_array <= s_expanded;
        wait for clk_period * (R + 3);
        assert (ciphertext = x"07AF72B83C99D33D");

        finish(0);

    end process stimuli;

end behavioral;
