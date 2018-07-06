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

    constant s_expanded : S := (x"9bbbd8c8", x"1a37f7fb", x"46F8E8C5", x"460C6085", x"70F83B8A",
                                x"284B8303", x"513E1454", x"F621ED22", x"3125065D", x"11A83A5D",
                                x"D427686B", x"713AD82D", x"4B792F99", x"2799A4DD", x"A7901C49",
                                x"DEDE871A", x"36C03196", x"A7EFC249", x"61A78BB8", x"3B0A1D2B",
                                x"4DBFCA76", x"AE162167", x"30D76B0A", x"43192304", x"F6CC1431",
                                x"65046380");

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

        key_array <= s_empty;
        wait for clk_period;

        plaintext <= x"8EC74320A138BCE0";
        key_array <= s_expanded;
        wait for clk_period * 50;
        assert (ciphertext = x"9B121890938518FF");

        key_array <= s_empty;
        wait for clk_period;

        plaintext <= x"9015DA409FEA25C0";
        key_array <= s_expanded;
        wait for clk_period * 50;
        assert (ciphertext = x"5C93F105E8DA3337");

        key_array <= s_empty;
        wait for clk_period;

        plaintext <= x"90BD25D09F42DA30";
        key_array <= s_expanded;
        wait for clk_period * 50;
        assert (ciphertext = x"93429D58963CDCDD");

        key_array <= s_empty;
        wait for clk_period;

        plaintext <= x"916471609E9B8EA0";
        key_array <= s_expanded;
        wait for clk_period * 50;
        assert (ciphertext = x"4E05B93F6EABA955");

        key_array <= s_empty;
        wait for clk_period;

        plaintext <= x"920BBCF09DF44310";
        key_array <= s_expanded;
        wait for clk_period * 50;
        assert (ciphertext = x"802F51F583FA6B9D");
        
    end process stimuli;

end behavioral;
